CREATE TABLE IF NOT EXISTS salary_scales_official (
    id BIGSERIAL PRIMARY KEY,
    salary_scale VARCHAR(30) NOT NULL,
    division VARCHAR(30) NOT NULL,
    min_notch INTEGER NOT NULL,
    max_notch INTEGER NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    authority_document VARCHAR(200),
    page_reference VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_salary_scales_official_notch_range CHECK (min_notch <= max_notch),
    CONSTRAINT uq_salary_scales_official UNIQUE (salary_scale, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_salary_scales_official_active
    ON salary_scales_official(is_active, salary_scale, effective_from DESC);

INSERT INTO salary_scales_official (
    salary_scale,
    division,
    min_notch,
    max_notch,
    effective_from,
    authority_document
) VALUES
('LGSS01', 'DIVISION_I',   1, 7, DATE '2025-01-01', 'Management Circular 2025'),
('LGSS02', 'DIVISION_I',   1, 7, DATE '2025-01-01', 'Management Circular 2025'),
('LGSS03', 'DIVISION_I',   1, 7, DATE '2025-01-01', 'Management Circular 2025'),
('LGSS04', 'DIVISION_I',   1, 7, DATE '2025-01-01', 'Management Circular 2025'),
('LGSS05', 'DIVISION_I',   1, 7, DATE '2025-01-01', 'Management Circular 2025'),
('LGSS06', 'DIVISION_I',   1, 7, DATE '2025-01-01', 'Management Circular 2025'),
('LGSS07', 'DIVISION_I',   1, 7, DATE '2025-01-01', 'Management Circular 2025'),
('LGSS08', 'DIVISION_II',  1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS09', 'DIVISION_II',  1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS10', 'DIVISION_II',  1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS11', 'DIVISION_II',  1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS12', 'DIVISION_II',  1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS13', 'DIVISION_III', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS14', 'DIVISION_III', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS15', 'DIVISION_III', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS16', 'DIVISION_III', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS17', 'DIVISION_III', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('LGSS18', 'DIVISION_III', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('GRADE_01', 'DIVISION_IV', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('GRADE_02', 'DIVISION_IV', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025'),
('GRADE_03', 'DIVISION_IV', 1, 7, DATE '2025-01-01', 'Collective Agreement 2025')
ON CONFLICT (salary_scale, effective_from) DO NOTHING;
