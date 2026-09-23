INSERT INTO company_documents (title, description, category, document_key, filename, file_path, mime_type, uploaded_by, is_active)
VALUES
    (
        'Terms and Conditions of Service',
        'Official terms and conditions for all employees of the Local Government Service Commission',
        'terms',
        'terms',
        'terms-and-conditions-local-government-service-commission.pdf',
        'classpath:documents/terms-and-conditions-local-government-service-commission.pdf',
        'application/pdf',
        'system',
        TRUE
    ),
    (
        'Disciplinary Code and Procedures for Handling Offences',
        'Comprehensive disciplinary framework and procedures for handling offences in the Local Government Service',
        'disciplinary',
        'disciplinary',
        'Disciplinary Code and Procedures for Handling Offences.pdf',
        'classpath:documents/Disciplinary Code and Procedures for Handling Offences.pdf',
        'application/pdf',
        'system',
        TRUE
    ),
    (
        'Grievance Handling Procedures in Public and Local Government',
        'Official procedures for handling grievances and complaints in the Public and Local Government Service',
        'grievance',
        'grievance',
        'Grievance Handling Procedures in Public and Local Government.pdf',
        'classpath:documents/Grievance Handling Procedures in Public and Local Government.pdf',
        'application/pdf',
        'system',
        TRUE
    ),
    (
        'Code of Ethics',
        'Code of ethics and professional conduct for all public and local government employees',
        'ethics',
        'ethics',
        'Code of Ethics.pdf',
        'classpath:documents/Code of Ethics.pdf',
        'application/pdf',
        'system',
        TRUE
    )
ON CONFLICT (document_key) DO UPDATE
SET title = EXCLUDED.title,
    description = EXCLUDED.description,
    category = EXCLUDED.category,
    filename = EXCLUDED.filename,
    file_path = EXCLUDED.file_path,
    mime_type = EXCLUDED.mime_type,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;
