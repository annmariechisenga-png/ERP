-- Seed additional standard work locations
-- Adds representative sites for satellite office, market, and refuse bay operations.

INSERT INTO work_locations (
    location_code,
    location_name,
    location_type,
    latitude,
    longitude,
    geofence_radius_meters,
    address,
    opens_at,
    closes_at,
    applicable_divisions,
    applicable_role_categories,
    is_active,
    is_primary
) VALUES
(
    'SAT01',
    'Satellite Office',
    'satellite_office',
    -15.86500000,
    27.74500000,
    120,
    'Council Satellite Office',
    TIME '07:30:00',
    TIME '17:00:00',
    '["I", "II", "III"]'::jsonb,
    '["office", "operator", "artisan"]'::jsonb,
    TRUE,
    TRUE
),
(
    'MKT01',
    'Main Market',
    'market',
    -15.87250000,
    27.75800000,
    120,
    'Council Market Operations Area',
    TIME '05:30:00',
    TIME '18:30:00',
    '["II", "III", "IV"]'::jsonb,
    '["operator", "cleaner", "driver", "garbage_collector", "sweeper"]'::jsonb,
    TRUE,
    TRUE
),
(
    'RFB01',
    'Main Refuse Bay',
    'refuse_bay',
    -15.87800000,
    27.77200000,
    150,
    'Primary Refuse Collection Bay',
    TIME '05:00:00',
    TIME '19:00:00',
    '["III", "IV"]'::jsonb,
    '["driver", "cleaner", "garbage_collector", "sweeper"]'::jsonb,
    TRUE,
    TRUE
)
ON CONFLICT (location_code) DO UPDATE SET
    location_name = EXCLUDED.location_name,
    location_type = EXCLUDED.location_type,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    geofence_radius_meters = EXCLUDED.geofence_radius_meters,
    address = EXCLUDED.address,
    opens_at = EXCLUDED.opens_at,
    closes_at = EXCLUDED.closes_at,
    applicable_divisions = EXCLUDED.applicable_divisions,
    applicable_role_categories = EXCLUDED.applicable_role_categories,
    is_active = EXCLUDED.is_active,
    is_primary = EXCLUDED.is_primary,
    updated_at = CURRENT_TIMESTAMP;
