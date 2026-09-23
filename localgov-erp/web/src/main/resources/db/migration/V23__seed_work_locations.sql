-- Seed default work locations
-- Coordinates are operational defaults and can be refined per council after deployment.

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
    'CIVIC',
    'Civic Centre',
    'headquarters',
    -15.86000000,
    27.76000000,
    150,
    'Council Civic Centre',
    TIME '07:30:00',
    TIME '17:30:00',
    '["I", "II", "III", "IV"]'::jsonb,
    '["office", "operator", "artisan", "driver", "cleaner", "gravedigger", "sweeper", "garbage_collector"]'::jsonb,
    TRUE,
    TRUE
),
(
    'CEM01',
    'Main Cemetery',
    'cemetery',
    -15.87000000,
    27.75000000,
    120,
    'Municipal cemetery operations point',
    TIME '06:00:00',
    TIME '18:00:00',
    '["III", "IV"]'::jsonb,
    '["driver", "cleaner", "gravedigger", "garbage_collector"]'::jsonb,
    TRUE,
    TRUE
),
(
    'DPOT01',
    'Main Depot',
    'depot',
    -15.85500000,
    27.77000000,
    150,
    'Primary depot and assembly point',
    TIME '05:30:00',
    TIME '19:00:00',
    '["II", "III", "IV"]'::jsonb,
    '["operator", "artisan", "driver", "cleaner", "garbage_collector"]'::jsonb,
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
