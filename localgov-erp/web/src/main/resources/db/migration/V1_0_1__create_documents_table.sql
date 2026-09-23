-- Create company documents table
CREATE TABLE IF NOT EXISTS company_documents (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    document_key VARCHAR(100) UNIQUE NOT NULL,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    uploaded_by VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_documents_category ON company_documents(category);
CREATE INDEX IF NOT EXISTS idx_documents_key ON company_documents(document_key);
CREATE INDEX IF NOT EXISTS idx_documents_active ON company_documents(is_active);

-- Insert the existing Terms and Conditions document
INSERT INTO company_documents (
    title, 
    description, 
    category, 
    document_key, 
    filename, 
    file_path, 
    file_size,
    mime_type,
    uploaded_by
) VALUES (
    'Terms and Conditions of Service',
    'Official terms and conditions for all employees of the Local Government Service Commission',
    'terms',
    'terms',
    'terms-and-conditions-local-government-service-commission.pdf',
    'classpath:documents/terms-and-conditions-local-government-service-commission.pdf',
    933510,
    'application/pdf',
    'system'
) ON CONFLICT (document_key) DO NOTHING;

-- Insert placeholder for Disciplinary Code and Procedures for Handling Offences
INSERT INTO company_documents (
    title,
    description,
    category,
    document_key,
    filename,
    file_path,
    uploaded_by,
    is_active
) VALUES (
    'Disciplinary Code and Procedures for Handling Offences',
    'Comprehensive disciplinary framework and procedures for handling offences in the Local Government Service',
    'disciplinary',
    'disciplinary',
    'placeholder.pdf',
    '',
    'system',
    FALSE
) ON CONFLICT (document_key) DO NOTHING;

-- Insert placeholder for Grievance Handling Procedures
INSERT INTO company_documents (
    title,
    description,
    category,
    document_key,
    filename,
    file_path,
    uploaded_by,
    is_active
) VALUES (
    'Grievance Handling Procedures in Public and Local Government',
    'Official procedures for handling grievances and complaints in the Public and Local Government Service',
    'grievance',
    'grievance',
    'placeholder.pdf',
    '',
    'system',
    FALSE
) ON CONFLICT (document_key) DO NOTHING;

-- Insert placeholder for Code of Ethics
INSERT INTO company_documents (
    title,
    description,
    category,
    document_key,
    filename,
    file_path,
    uploaded_by,
    is_active
) VALUES (
    'Code of Ethics',
    'Code of ethics and professional conduct for all public and local government employees',
    'ethics',
    'ethics',
    'placeholder.pdf',
    '',
    'system',
    FALSE
) ON CONFLICT (document_key) DO NOTHING;
