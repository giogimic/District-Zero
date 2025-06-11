-- Migration: Create missions table
CREATE TABLE IF NOT EXISTS `dz_missions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `title` varchar(255) NOT NULL,
    `description` text NOT NULL,
    `difficulty` enum('easy','medium','hard') NOT NULL DEFAULT 'medium',
    `required_level` int(11) DEFAULT NULL,
    `required_items` json DEFAULT NULL,
    `reward` json NOT NULL,
    `objectives` json NOT NULL,
    `start_coords` json NOT NULL,
    `start_blip` int(11) DEFAULT 1,
    `start_label` varchar(255) DEFAULT 'Mission Start',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Migration: Create mission progress table
CREATE TABLE IF NOT EXISTS `dz_mission_progress` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `mission_id` int(11) NOT NULL,
    `citizenid` varchar(50) NOT NULL,
    `status` enum('active','completed','failed') NOT NULL DEFAULT 'active',
    `objectives_completed` json DEFAULT NULL,
    `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `completed_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `mission_id` (`mission_id`),
    KEY `citizenid` (`citizenid`),
    CONSTRAINT `fk_mission_progress_mission` FOREIGN KEY (`mission_id`) REFERENCES `dz_missions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Migration: Create mission completion history
CREATE TABLE IF NOT EXISTS `dz_mission_history` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `mission_id` int(11) NOT NULL,
    `citizenid` varchar(50) NOT NULL,
    `status` enum('completed','failed') NOT NULL,
    `completion_time` int(11) DEFAULT NULL,
    `reward_received` json DEFAULT NULL,
    `completed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `mission_id` (`mission_id`),
    KEY `citizenid` (`citizenid`),
    CONSTRAINT `fk_mission_history_mission` FOREIGN KEY (`mission_id`) REFERENCES `dz_missions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; 