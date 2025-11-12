-- Seed sample data
-- This seed is idempotent - can be run multiple times safely

INSERT INTO sample_data (key, value) VALUES
    ('welcome', '{"message": "Welcome to Wander Developer Environment", "version": "1.0.0"}'::jsonb),
    ('config', '{"theme": "dark", "language": "en"}'::jsonb),
    ('stats', '{"users": 5, "services": 4, "uptime": "100%"}'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- Verify seed
SELECT COUNT(*) as total_data FROM sample_data;

