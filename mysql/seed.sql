-- Seed data for MaaS MySQL schema
-- Run after schema.sql is applied (and after USE <database> if needed).

-- Transport modes
INSERT INTO transport_modes (name, code) VALUES
  ('Bus', 'BUS'),
  ('Metro', 'METRO'),
  ('Ferry', 'FERRY')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Pass types
INSERT INTO pass_types (name, validity_days, price, max_trips_per_day) VALUES
  ('Daily Pass', 1, 2.50, 10),
  ('Weekly Metro Pass', 7, 15.00, NULL)
ON DUPLICATE KEY UPDATE validity_days = VALUES(validity_days), price = VALUES(price), max_trips_per_day = VALUES(max_trips_per_day);

-- Link pass types to transport modes
-- Use INSERT ... SELECT to avoid needing IDs explicitly
INSERT IGNORE INTO pass_type_transport_modes (pass_type_id, transport_mode_id)
SELECT pt.id, tm.id
FROM pass_types pt
JOIN transport_modes tm ON tm.code IN ('BUS', 'METRO')
WHERE pt.name = 'Daily Pass';

INSERT IGNORE INTO pass_type_transport_modes (pass_type_id, transport_mode_id)
SELECT pt.id, tm.id
FROM pass_types pt
JOIN transport_modes tm ON tm.code = 'METRO'
WHERE pt.name = 'Weekly Metro Pass';

-- User
INSERT INTO users (name, mobile, email, password_hash, role)
VALUES ('Alice Rider', '+15550001234', 'alice@example.com', 'hashed_password_example', 'rider')
ON DUPLICATE KEY UPDATE name = VALUES(name), mobile = VALUES(mobile), role = VALUES(role);

-- User pass
INSERT INTO user_passes (user_id, pass_type_id, pass_code, purchase_date, expiry_date, status)
SELECT u.id, pt.id, 'PASS-ABC-123', '2026-03-10 00:00:00', '2026-03-11 00:00:00', 'active'
FROM users u
JOIN pass_types pt ON pt.name = 'Daily Pass'
WHERE u.email = 'alice@example.com'
ON DUPLICATE KEY UPDATE status = VALUES(status), expiry_date = VALUES(expiry_date);

-- Trip
INSERT INTO trips (user_pass_id, validated_by, transport_mode_id, route_info)
SELECT up.id, NULL, tm.id, JSON_OBJECT('from','Main St','to','Central Station','line','10')
FROM user_passes up
JOIN transport_modes tm ON tm.code = 'BUS'
WHERE up.pass_code = 'PASS-ABC-123';
