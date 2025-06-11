-- Migration: Create missions table
CREATE TABLE IF NOT EXISTS `dz_missions` (
    `id` VARCHAR(50) NOT NULL,
    `title` VARCHAR(100) NOT NULL,
    `description` TEXT NOT NULL,
    `difficulty` ENUM('easy', 'medium', 'hard') NOT NULL DEFAULT 'medium',
    `reward` INT NOT NULL DEFAULT 0,
    `objectives` JSON NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Migration: Create mission progress table
CREATE TABLE IF NOT EXISTS `dz_mission_progress` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `mission_id` VARCHAR(50) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `status` ENUM('active', 'completed', 'failed') NOT NULL DEFAULT 'active',
    `started_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL DEFAULT NULL,
    `objectives_completed` JSON NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`mission_id`) REFERENCES `dz_missions` (`id`) ON DELETE CASCADE,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 