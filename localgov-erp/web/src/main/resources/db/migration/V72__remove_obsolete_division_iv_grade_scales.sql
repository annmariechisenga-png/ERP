-- Remove obsolete Division IV salary-scale codes.
-- Canonical Division IV codes are G1, G2, and G3.
DELETE FROM salary_scales_official
WHERE salary_scale IN ('GRADE_01', 'GRADE_02', 'GRADE_03');
