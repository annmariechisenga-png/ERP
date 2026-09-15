ALTER TABLE organisation_structure_import_staging
    ADD COLUMN is_attached BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE organisation_structure_import_staging
    DROP CONSTRAINT IF EXISTS chk_org_import_letter_scale_frozen;

ALTER TABLE organisation_structure_import_staging
    DROP CONSTRAINT IF EXISTS chk_org_import_ungraded_scale_frozen;

ALTER TABLE organisation_structure_import_staging
    ADD CONSTRAINT chk_org_import_attached_active
        CHECK (is_attached = FALSE OR is_active = TRUE);