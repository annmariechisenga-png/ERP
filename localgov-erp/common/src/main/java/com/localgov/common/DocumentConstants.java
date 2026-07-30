package com.localgov.common;

import java.util.List;
import java.util.Map;

public class DocumentConstants {

    private static final String DOCUMENTS_CLASSPATH = "documents/";

    // Document Keys
    public static final String DOC_TERMS        = "terms";
    public static final String DOC_DISCIPLINARY = "disciplinary";
    public static final String DOC_GRIEVANCE    = "grievance";
    public static final String DOC_ETHICS       = "ethics";

    // Document Categories
    public static final String CAT_TERMS        = "terms";
    public static final String CAT_DISCIPLINARY = "disciplinary";
    public static final String CAT_GRIEVANCE    = "grievance";
    public static final String CAT_ETHICS       = "ethics";

    // Document registry
    public static final Map<String, DocumentInfo> DOCUMENTS = Map.of(

        DOC_TERMS, new DocumentInfo(
            "Terms and Conditions of Service",
            "Official terms and conditions for all employees of the Local Government Service Commission",
            CAT_TERMS,
            "terms-and-conditions-local-government-service-commission.pdf",
            "Terms and Conditions of Service - Local Government Service Commission.pdf"
        ),

        DOC_DISCIPLINARY, new DocumentInfo(
            "Disciplinary Code and Procedures for Handling Offences",
            "Comprehensive disciplinary framework and procedures for handling offences in the Local Government Service",
            CAT_DISCIPLINARY,
            "Disciplinary Code and Procedures for Handling Offences.pdf",
            "Disciplinary Code and Procedures for Handling Offences - Local Government Service.pdf"
        ),

        DOC_GRIEVANCE, new DocumentInfo(
            "Grievance Handling Procedures in Public and Local Government",
            "Official procedures for handling grievances and complaints in the Public and Local Government Service",
            CAT_GRIEVANCE,
            "Grievance Handling Procedures in Public and Local Government.pdf",
            "Grievance Handling Procedures in Public and Local Government.pdf"
        ),

        DOC_ETHICS, new DocumentInfo(
            "Code of Ethics",
            "Code of ethics and professional conduct for all public and local government employees",
            CAT_ETHICS,
            "Code of Ethics.pdf",
            "Code of Ethics - Local Government Service.pdf"
        )
    );

    public static List<String> getAllDocumentKeys() {
        return List.of(DOC_TERMS, DOC_DISCIPLINARY, DOC_GRIEVANCE, DOC_ETHICS);
    }

    // -----------------------------------------------------------------------
    // Inner record
    // -----------------------------------------------------------------------

    public static class DocumentInfo {
        private final String title;
        private final String description;
        private final String category;
        /** Filename inside src/main/resources/documents/ */
        private final String resourceFilename;
        /** Value used in Content-Disposition when serving the file */
        private final String downloadFilename;

        public DocumentInfo(String title, String description, String category,
                            String resourceFilename, String downloadFilename) {
            this.title            = title;
            this.description      = description;
            this.category         = category;
            this.resourceFilename = resourceFilename;
            this.downloadFilename = downloadFilename;
        }

        public String getTitle()            { return title; }
        public String getDescription()      { return description; }
        public String getCategory()         { return category; }
        public String getResourceFilename() { return resourceFilename; }
        public String getDownloadFilename() { return downloadFilename; }

        /** Classpath location, e.g. {@code documents/code-of-ethics.pdf} */
        public String getClasspathLocation() {
            return DOCUMENTS_CLASSPATH + resourceFilename;
        }
    }
}
