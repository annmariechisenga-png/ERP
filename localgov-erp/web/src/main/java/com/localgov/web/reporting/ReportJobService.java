package com.localgov.web.reporting;

import com.localgov.web.reporting.dto.ReportJobResponse;
import com.localgov.web.reporting.dto.ViewReportResponse;
import org.springframework.core.task.TaskExecutor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ReportJobService {

    private static final String STATUS_SUBMITTED = "SUBMITTED";
    private static final String STATUS_RUNNING = "RUNNING";
    private static final String STATUS_COMPLETED = "COMPLETED";
    private static final String STATUS_FAILED = "FAILED";

    private final ReportingService reportingService;
    private final TaskExecutor taskExecutor;

    private final Map<String, MutableReportJob> jobs = new ConcurrentHashMap<>();

    public ReportJobService(ReportingService reportingService, TaskExecutor taskExecutor) {
        this.reportingService = reportingService;
        this.taskExecutor = taskExecutor;
    }

    public ReportJobResponse submitViewJob(String viewName, Integer offset, Integer limit) {
        String jobId = UUID.randomUUID().toString();
        MutableReportJob job = new MutableReportJob(
                jobId,
                STATUS_SUBMITTED,
                viewName,
                offset,
                limit,
                LocalDateTime.now(),
                null,
                null,
                null,
                null
        );
        jobs.put(jobId, job);

        taskExecutor.execute(() -> runViewJob(jobId));
        return job.toResponse();
    }

    public ReportJobResponse getJob(String jobId) {
        MutableReportJob job = jobs.get(jobId);
        if (job == null) {
            return null;
        }
        return job.toResponse();
    }

    private void runViewJob(String jobId) {
        MutableReportJob job = jobs.get(jobId);
        if (job == null) {
            return;
        }

        job.status = STATUS_RUNNING;
        job.startedAt = LocalDateTime.now();

        try {
            ViewReportResponse report = reportingService.readView(job.viewName, job.offset, job.limit);
            job.result = report;
            job.status = STATUS_COMPLETED;
            job.completedAt = LocalDateTime.now();
        } catch (Exception exception) {
            job.status = STATUS_FAILED;
            job.error = exception.getMessage();
            job.completedAt = LocalDateTime.now();
        }
    }

    private static class MutableReportJob {
        private final String jobId;
        private String status;
        private final String viewName;
        private final Integer offset;
        private final Integer limit;
        private final LocalDateTime submittedAt;
        private LocalDateTime startedAt;
        private LocalDateTime completedAt;
        private String error;
        private ViewReportResponse result;

        private MutableReportJob(
                String jobId,
                String status,
                String viewName,
                Integer offset,
                Integer limit,
                LocalDateTime submittedAt,
                LocalDateTime startedAt,
                LocalDateTime completedAt,
                String error,
                ViewReportResponse result
        ) {
            this.jobId = jobId;
            this.status = status;
            this.viewName = viewName;
            this.offset = offset;
            this.limit = limit;
            this.submittedAt = submittedAt;
            this.startedAt = startedAt;
            this.completedAt = completedAt;
            this.error = error;
            this.result = result;
        }

        private ReportJobResponse toResponse() {
            return new ReportJobResponse(
                    jobId,
                    status,
                    viewName,
                    offset,
                    limit,
                    submittedAt,
                    startedAt,
                    completedAt,
                    error,
                    result
            );
        }
    }
}
