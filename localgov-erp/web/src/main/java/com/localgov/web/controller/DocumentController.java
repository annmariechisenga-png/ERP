package com.localgov.web.controller;

import com.localgov.common.DocumentConstants;
import com.localgov.common.DocumentConstants.DocumentInfo;
import com.localgov.domain.model.CompanyDocument;
import com.localgov.repository.CompanyDocumentRepository;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.springframework.http.HttpStatus.NOT_FOUND;
import static org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE;

@Tag(name = "Documents", description = "Employee-facing policy and HR documents")
@RestController
@RequestMapping("/documents")
public class DocumentController {

    private final CompanyDocumentRepository companyDocumentRepository;

    public DocumentController(CompanyDocumentRepository companyDocumentRepository) {
        this.companyDocumentRepository = companyDocumentRepository;
    }

    // ------------------------------------------------------------------
    // List all documents
    // ------------------------------------------------------------------

    @Operation(summary = "List all HR / policy documents with availability status")
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<Map<String, Object>>> listDocuments() {

        List<CompanyDocument> records = companyDocumentRepository.findAllByOrderByIdAsc();
        List<Map<String, Object>> list;

        if (records.isEmpty()) {
            list = DocumentConstants.getAllDocumentKeys()
                    .stream()
                    .map(this::buildLegacyEntry)
                    .toList();
        } else {
            list = records.stream()
                    .map(this::buildDatabaseEntry)
                    .toList();
        }

        return ResponseEntity.ok(list);
    }

    // ------------------------------------------------------------------
    // Serve a document — GET /documents/{key}?action=view|download|print
    // ------------------------------------------------------------------

    @Operation(summary = "View, download or print an HR / policy document")
    @GetMapping(value = "/{key}", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<Resource> serveDocument(
            @Parameter(description = "Document key: terms | disciplinary | grievance | ethics")
            @PathVariable String key,

            @Parameter(description = "Render mode: view (default, inline) | download (attachment) | print (inline)")
            @RequestParam(name = "action", defaultValue = "view") String action
    ) {
        CompanyDocument record = companyDocumentRepository.findByDocumentKeyIgnoreCase(key).orElse(null);
        DocumentInfo fallbackInfo = DocumentConstants.DOCUMENTS.get(key);

        if (record == null && fallbackInfo == null) {
            throw new ResponseStatusException(NOT_FOUND,
                    "Unknown document key '" + key + "'. " +
                    "Valid keys: " + DocumentConstants.getAllDocumentKeys());
        }

        Resource resource = resolveResource(record, fallbackInfo);
        boolean available = isAvailable(record, resource);
        String title = record != null && record.getTitle() != null ? record.getTitle() : fallbackInfo.getTitle();
        String downloadFilename = record != null && record.getFilename() != null && !record.getFilename().isBlank()
                ? record.getFilename()
                : fallbackInfo.getDownloadFilename();

        if (!available) {
            throw new ResponseStatusException(SERVICE_UNAVAILABLE,
                    "Document '" + title + "' has not been uploaded yet. " +
                    "Please contact HR to make this document available.");
        }

        boolean asAttachment = "download".equalsIgnoreCase(action);

        ContentDisposition disposition = asAttachment
                ? ContentDisposition.attachment().filename(downloadFilename).build()
                : ContentDisposition.inline().filename(downloadFilename).build();

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .header(HttpHeaders.CACHE_CONTROL, "no-store")
                .contentType(MediaType.APPLICATION_PDF)
                .body(resource);
    }

    private Map<String, Object> buildLegacyEntry(String key) {
        DocumentInfo info = DocumentConstants.DOCUMENTS.get(key);
        boolean available = new ClassPathResource(info.getClasspathLocation()).exists();

        Map<String, Object> entry = new LinkedHashMap<>();
        entry.put("key", key);
        entry.put("title", info.getTitle());
        entry.put("description", info.getDescription());
        entry.put("category", info.getCategory());
        entry.put("available", available);
        entry.put("viewUrl", "/documents/" + key + "?action=view");
        entry.put("downloadUrl", "/documents/" + key + "?action=download");
        entry.put("printUrl", "/documents/" + key + "?action=print");
        return entry;
    }

    private Map<String, Object> buildDatabaseEntry(CompanyDocument document) {
        String key = document.getDocumentKey();
        DocumentInfo fallbackInfo = DocumentConstants.DOCUMENTS.get(key);
        Resource resource = resolveResource(document, fallbackInfo);

        Map<String, Object> entry = new LinkedHashMap<>();
        entry.put("key", key);
        entry.put("title", firstNonBlank(document.getTitle(), fallbackInfo != null ? fallbackInfo.getTitle() : key));
        entry.put("description", firstNonBlank(document.getDescription(), fallbackInfo != null ? fallbackInfo.getDescription() : "Official employee document"));
        entry.put("category", firstNonBlank(document.getCategory(), fallbackInfo != null ? fallbackInfo.getCategory() : "general"));
        entry.put("available", isAvailable(document, resource));
        entry.put("viewUrl", "/documents/" + key + "?action=view");
        entry.put("downloadUrl", "/documents/" + key + "?action=download");
        entry.put("printUrl", "/documents/" + key + "?action=print");
        return entry;
    }

    private boolean isAvailable(CompanyDocument document, Resource resource) {
        boolean active = document == null || !Boolean.FALSE.equals(document.getActive());
        return active && resource != null && resource.exists();
    }

    private Resource resolveResource(CompanyDocument document, DocumentInfo fallbackInfo) {
        if (document != null && document.getFilePath() != null && !document.getFilePath().isBlank()) {
            String filePath = document.getFilePath().trim();
            if (filePath.startsWith("classpath:")) {
                return new ClassPathResource(filePath.substring("classpath:".length()));
            }
            return new FileSystemResource(filePath);
        }

        if (fallbackInfo != null) {
            return new ClassPathResource(fallbackInfo.getClasspathLocation());
        }

        return null;
    }

    private String firstNonBlank(String primary, String fallback) {
        return primary != null && !primary.isBlank() ? primary : fallback;
    }

    // ------------------------------------------------------------------
    // Legacy aliases — kept for backward compatibility
    // ------------------------------------------------------------------

    @GetMapping(value = "/terms-and-conditions", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<Resource> termsView(
            @RequestParam(name = "action", defaultValue = "view") String action) {
        return serveDocument(DocumentConstants.DOC_TERMS, action);
    }

    @GetMapping(value = "/terms-and-conditions/download", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<Resource> termsDownload() {
        return serveDocument(DocumentConstants.DOC_TERMS, "download");
    }

    @GetMapping(value = "/terms-and-conditions/print", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<Resource> termsPrint() {
        return serveDocument(DocumentConstants.DOC_TERMS, "print");
    }
}
