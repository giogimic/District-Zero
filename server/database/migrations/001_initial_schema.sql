-- Initial schema for District Zero
CREATE TABLE IF NOT EXISTS `dz_districts` (
    `id` VARCHAR(50) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `influence_pvp` INT DEFAULT 0,
    `influence_pve` INT DEFAULT 0,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `dz_control_points` (
    `id` INT AUTO_INCREMENT,
    `district_id` VARCHAR(50) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `coords_x` FLOAT NOT NULL,
    `coords_y` FLOAT NOT NULL,
    `coords_z` FLOAT NOT NULL,
    `radius` FLOAT NOT NULL,
    `influence` INT DEFAULT 25,
    `current_team` VARCHAR(10) DEFAULT 'neutral',
    `last_captured` TIMESTAMP NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`district_id`) REFERENCES `dz_districts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `dz_missions` (
    `id` VARCHAR(50) NOT NULL,
    `title` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `type` ENUM('pvp', 'pve') NOT NULL,
    `district_id` VARCHAR(50) NOT NULL,
    `reward` INT NOT NULL,
    `objectives` JSON NOT NULL,
    `active` BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`district_id`) REFERENCES `dz_districts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `dz_mission_progress` (
    `id` INT AUTO_INCREMENT,
    `mission_id` VARCHAR(50) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `status` ENUM('active', 'completed', 'failed') NOT NULL,
    `started_at` TIMESTAMP NOT NULL,
    `completed_at` TIMESTAMP NULL,
    `objectives_completed` JSON DEFAULT '[]',
    PRIMARY KEY (`id`),
    FOREIGN KEY (`mission_id`) REFERENCES `dz_missions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `dz_player_teams` (
    `citizenid` VARCHAR(50) NOT NULL,
    `team` ENUM('pvp', 'pve') NOT NULL,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; 