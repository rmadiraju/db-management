-- Insert sample users data
-- Version: 1.0
-- Description: Sample user data for testing

INSERT INTO users (username, email, first_name, last_name, password_hash, is_active) VALUES
('john_doe', 'john.doe@example.com', 'John', 'Doe', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', true),
('jane_smith', 'jane.smith@example.com', 'Jane', 'Smith', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', true),
('bob_wilson', 'bob.wilson@example.com', 'Bob', 'Wilson', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', false),
('alice_brown', 'alice.brown@example.com', 'Alice', 'Brown', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', true)
ON CONFLICT (username) DO NOTHING;

-- Update sequence to avoid conflicts
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
