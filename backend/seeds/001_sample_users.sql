-- Seed sample users data
-- This seed is idempotent - can be run multiple times safely

INSERT INTO users (name, email) VALUES
    ('Alice Developer', 'alice@wander.dev'),
    ('Bob Engineer', 'bob@wander.dev'),
    ('Charlie Coder', 'charlie@wander.dev'),
    ('Diana Designer', 'diana@wander.dev'),
    ('Eve Engineer', 'eve@wander.dev')
ON CONFLICT (email) DO NOTHING;

-- Verify seed
SELECT COUNT(*) as total_users FROM users;

