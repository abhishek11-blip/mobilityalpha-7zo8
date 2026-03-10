-- MySQL schema for Mobility-as-a-Service (MaaS)
-- Run with: mysql -u <user> -p < database_name < schema.sql

SET FOREIGN_KEY_CHECKS = 0;

-- Create the database if it does not exist (optional)
-- CREATE DATABASE IF NOT EXISTS mobility_maas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE mobility_maas;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  mobile VARCHAR(32) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS transport_modes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  code VARCHAR(32) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS pass_types (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  validity_days INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  max_trips_per_day INT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS pass_type_transport_modes (
  pass_type_id BIGINT UNSIGNED NOT NULL,
  transport_mode_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (pass_type_id, transport_mode_id),
  CONSTRAINT fk_pttm_pass_type FOREIGN KEY (pass_type_id) REFERENCES pass_types(id) ON DELETE CASCADE,
  CONSTRAINT fk_pttm_transport_mode FOREIGN KEY (transport_mode_id) REFERENCES transport_modes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_passes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  pass_type_id BIGINT UNSIGNED NOT NULL,
  pass_code VARCHAR(255) NOT NULL UNIQUE,
  purchase_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expiry_date DATETIME NOT NULL,
  status VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_passes_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_passes_pass_type FOREIGN KEY (pass_type_id) REFERENCES pass_types(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trips (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_pass_id BIGINT UNSIGNED NOT NULL,
  validated_by BIGINT UNSIGNED DEFAULT NULL,
  transport_mode_id BIGINT UNSIGNED NOT NULL,
  route_info JSON DEFAULT NULL,
  validated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_trips_user_pass FOREIGN KEY (user_pass_id) REFERENCES user_passes(id) ON DELETE CASCADE,
  CONSTRAINT fk_trips_validated_by FOREIGN KEY (validated_by) REFERENCES users(id),
  CONSTRAINT fk_trips_transport_mode FOREIGN KEY (transport_mode_id) REFERENCES transport_modes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
