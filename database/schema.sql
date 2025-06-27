-- District Zero FiveM - Database Schema
-- This file contains all the necessary database tables and structure

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS `district_zero` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `district_zero`;

-- Players table
CREATE TABLE IF NOT EXISTS `players` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `level` INT DEFAULT 1,
    `experience` INT DEFAULT 0,
    `money` DECIMAL(15,2) DEFAULT 0.00,
    `bank` DECIMAL(15,2) DEFAULT 0.00,
    `team_id` INT NULL,
    `last_login` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_identifier` (`identifier`),
    INDEX `idx_team_id` (`team_id`),
    INDEX `idx_level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Teams table
CREATE TABLE IF NOT EXISTS `teams` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `leader_id` INT NOT NULL,
    `description` TEXT,
    `color` VARCHAR(7) DEFAULT '#FFFFFF',
    `max_members` INT DEFAULT 8,
    `current_members` INT DEFAULT 1,
    `total_captures` INT DEFAULT 0,
    `total_missions` INT DEFAULT 0,
    `total_events` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_leader_id` (`leader_id`),
    INDEX `idx_name` (`name`),
    INDEX `idx_total_captures` (`total_captures`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Districts table
CREATE TABLE IF NOT EXISTS `districts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `coordinates` JSON NOT NULL,
    `radius` FLOAT DEFAULT 50.0,
    `capture_time` INT DEFAULT 300,
    `reward_multiplier` DECIMAL(3,2) DEFAULT 1.00,
    `respawn_time` INT DEFAULT 60,
    `max_players` INT DEFAULT 10,
    `current_owner_id` INT NULL,
    `capture_progress` INT DEFAULT 0,
    `last_captured` TIMESTAMP NULL,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_current_owner_id` (`current_owner_id`),
    INDEX `idx_is_active` (`is_active`),
    INDEX `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- District captures history
CREATE TABLE IF NOT EXISTS `district_captures` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `district_id` INT NOT NULL,
    `team_id` INT NOT NULL,
    `captured_by` INT NOT NULL,
    `capture_time` INT NOT NULL,
    `captured_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_district_id` (`district_id`),
    INDEX `idx_team_id` (`team_id`),
    INDEX `idx_captured_by` (`captured_by`),
    INDEX `idx_captured_at` (`captured_at`),
    FOREIGN KEY (`district_id`) REFERENCES `districts`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`team_id`) REFERENCES `teams`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`captured_by`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Missions table
CREATE TABLE IF NOT EXISTS `missions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `type` ENUM('capture', 'defend', 'escort', 'delivery', 'elimination') NOT NULL,
    `difficulty` ENUM('easy', 'medium', 'hard', 'expert') DEFAULT 'medium',
    `district_id` INT NULL,
    `coordinates` JSON,
    `target_coordinates` JSON,
    `reward_money` DECIMAL(15,2) DEFAULT 0.00,
    `reward_experience` INT DEFAULT 0,
    `time_limit` INT DEFAULT 1800,
    `min_players` INT DEFAULT 1,
    `max_players` INT DEFAULT 5,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_type` (`type`),
    INDEX `idx_difficulty` (`difficulty`),
    INDEX `idx_district_id` (`district_id`),
    INDEX `idx_is_active` (`is_active`),
    FOREIGN KEY (`district_id`) REFERENCES `districts`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Mission assignments
CREATE TABLE IF NOT EXISTS `mission_assignments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `mission_id` INT NOT NULL,
    `player_id` INT NOT NULL,
    `team_id` INT NULL,
    `status` ENUM('assigned', 'in_progress', 'completed', 'failed', 'abandoned') DEFAULT 'assigned',
    `started_at` TIMESTAMP NULL,
    `completed_at` TIMESTAMP NULL,
    `progress` INT DEFAULT 0,
    `reward_received` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_mission_id` (`mission_id`),
    INDEX `idx_player_id` (`player_id`),
    INDEX `idx_team_id` (`team_id`),
    INDEX `idx_status` (`status`),
    UNIQUE KEY `unique_mission_player` (`mission_id`, `player_id`),
    FOREIGN KEY (`mission_id`) REFERENCES `missions`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`team_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Events table
CREATE TABLE IF NOT EXISTS `events` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `type` ENUM('capture', 'team_battle', 'competition', 'special') NOT NULL,
    `start_time` TIMESTAMP NOT NULL,
    `end_time` TIMESTAMP NOT NULL,
    `max_participants` INT DEFAULT 50,
    `current_participants` INT DEFAULT 0,
    `reward_pool` DECIMAL(15,2) DEFAULT 0.00,
    `status` ENUM('scheduled', 'active', 'completed', 'cancelled') DEFAULT 'scheduled',
    `created_by` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_type` (`type`),
    INDEX `idx_start_time` (`start_time`),
    INDEX `idx_status` (`status`),
    INDEX `idx_created_by` (`created_by`),
    FOREIGN KEY (`created_by`) REFERENCES `players`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Event participants
CREATE TABLE IF NOT EXISTS `event_participants` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `event_id` INT NOT NULL,
    `player_id` INT NOT NULL,
    `team_id` INT NULL,
    `joined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `left_at` TIMESTAMP NULL,
    `final_score` INT DEFAULT 0,
    `final_rank` INT NULL,
    `reward_received` BOOLEAN DEFAULT FALSE,
    INDEX `idx_event_id` (`event_id`),
    INDEX `idx_player_id` (`player_id`),
    INDEX `idx_team_id` (`team_id`),
    UNIQUE KEY `unique_event_player` (`event_id`, `player_id`),
    FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`team_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Achievements table
CREATE TABLE IF NOT EXISTS `achievements` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `category` ENUM('districts', 'missions', 'teams', 'events', 'general') NOT NULL,
    `type` ENUM('progress', 'milestone', 'special') DEFAULT 'progress',
    `requirement_type` ENUM('captures', 'missions', 'events', 'time', 'custom') NOT NULL,
    `requirement_value` INT NOT NULL,
    `reward_money` DECIMAL(15,2) DEFAULT 0.00,
    `reward_experience` INT DEFAULT 0,
    `icon` VARCHAR(255),
    `is_hidden` BOOLEAN DEFAULT FALSE,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_category` (`category`),
    INDEX `idx_type` (`type`),
    INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Player achievements
CREATE TABLE IF NOT EXISTS `player_achievements` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT NOT NULL,
    `achievement_id` INT NOT NULL,
    `progress` INT DEFAULT 0,
    `completed` BOOLEAN DEFAULT FALSE,
    `unlocked_at` TIMESTAMP NULL,
    `reward_received` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_player_id` (`player_id`),
    INDEX `idx_achievement_id` (`achievement_id`),
    INDEX `idx_completed` (`completed`),
    UNIQUE KEY `unique_player_achievement` (`player_id`, `achievement_id`),
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`achievement_id`) REFERENCES `achievements`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Analytics table
CREATE TABLE IF NOT EXISTS `analytics` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT NULL,
    `team_id` INT NULL,
    `event_type` VARCHAR(50) NOT NULL,
    `event_data` JSON,
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_player_id` (`player_id`),
    INDEX `idx_team_id` (`team_id`),
    INDEX `idx_event_type` (`event_type`),
    INDEX `idx_timestamp` (`timestamp`),
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`team_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Security violations
CREATE TABLE IF NOT EXISTS `security_violations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT NOT NULL,
    `violation_type` ENUM('speed_hack', 'teleport_hack', 'weapon_hack', 'rate_limit', 'invalid_input', 'other') NOT NULL,
    `description` TEXT,
    `severity` ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    `evidence` JSON,
    `action_taken` ENUM('warning', 'kick', 'ban', 'none') DEFAULT 'none',
    `resolved` BOOLEAN DEFAULT FALSE,
    `resolved_by` INT NULL,
    `resolved_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_player_id` (`player_id`),
    INDEX `idx_violation_type` (`violation_type`),
    INDEX `idx_severity` (`severity`),
    INDEX `idx_resolved` (`resolved`),
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`resolved_by`) REFERENCES `players`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Performance metrics
CREATE TABLE IF NOT EXISTS `performance_metrics` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `metric_type` ENUM('cpu', 'memory', 'database', 'network', 'custom') NOT NULL,
    `metric_name` VARCHAR(100) NOT NULL,
    `metric_value` FLOAT NOT NULL,
    `metric_unit` VARCHAR(20),
    `context` JSON,
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_metric_type` (`metric_type`),
    INDEX `idx_metric_name` (`metric_name`),
    INDEX `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Configuration table
CREATE TABLE IF NOT EXISTS `configuration` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `config_key` VARCHAR(100) NOT NULL UNIQUE,
    `config_value` JSON NOT NULL,
    `description` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Error logs table
CREATE TABLE IF NOT EXISTS `error_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `level` ENUM('debug', 'info', 'warn', 'error', 'critical') NOT NULL,
    `source` VARCHAR(100) NOT NULL,
    `message` TEXT NOT NULL,
    `stack_trace` TEXT,
    `context` JSON,
    `player_id` INT NULL,
    `resolved` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_level` (`level`),
    INDEX `idx_source` (`source`),
    INDEX `idx_player_id` (`player_id`),
    INDEX `idx_created_at` (`created_at`),
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add foreign key constraints for players table
ALTER TABLE `players` 
ADD CONSTRAINT `fk_players_team` 
FOREIGN KEY (`team_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL;

-- Add foreign key constraints for teams table
ALTER TABLE `teams` 
ADD CONSTRAINT `fk_teams_leader` 
FOREIGN KEY (`leader_id`) REFERENCES `players`(`id`) ON DELETE CASCADE;

-- Add foreign key constraints for districts table
ALTER TABLE `districts` 
ADD CONSTRAINT `fk_districts_owner` 
FOREIGN KEY (`current_owner_id`) REFERENCES `teams`(`id`) ON DELETE SET NULL;

-- Insert default achievements
INSERT IGNORE INTO `achievements` (`name`, `description`, `category`, `type`, `requirement_type`, `requirement_value`, `reward_money`, `reward_experience`) VALUES
('First Capture', 'Capture your first district', 'districts', 'milestone', 'captures', 1, 1000.00, 100),
('District Master', 'Capture 10 districts', 'districts', 'progress', 'captures', 10, 5000.00, 500),
('Team Leader', 'Create your first team', 'teams', 'milestone', 'custom', 1, 2000.00, 200),
('Mission Runner', 'Complete 5 missions', 'missions', 'progress', 'missions', 5, 3000.00, 300),
('Event Champion', 'Win your first event', 'events', 'milestone', 'events', 1, 5000.00, 500),
('Veteran Player', 'Play for 24 hours total', 'general', 'progress', 'time', 86400, 10000.00, 1000);

-- Insert default configuration
INSERT IGNORE INTO `configuration` (`config_key`, `config_value`, `description`) VALUES
('system_version', '"1.0.0"', 'Current system version'),
('maintenance_mode', 'false', 'System maintenance mode'),
('debug_mode', 'false', 'Debug mode enabled'),
('auto_backup', 'true', 'Automatic database backup'),
('backup_interval', '86400', 'Backup interval in seconds');

-- Create indexes for better performance
CREATE INDEX `idx_players_team_level` ON `players` (`team_id`, `level`);
CREATE INDEX `idx_teams_leader_members` ON `teams` (`leader_id`, `current_members`);
CREATE INDEX `idx_districts_owner_active` ON `districts` (`current_owner_id`, `is_active`);
CREATE INDEX `idx_missions_type_active` ON `missions` (`type`, `is_active`);
CREATE INDEX `idx_events_status_time` ON `events` (`status`, `start_time`);
CREATE INDEX `idx_analytics_player_type` ON `analytics` (`player_id`, `event_type`);
CREATE INDEX `idx_security_player_type` ON `security_violations` (`player_id`, `violation_type`);

-- Create views for common queries
CREATE OR REPLACE VIEW `player_stats` AS
SELECT 
    p.id,
    p.name,
    p.level,
    p.experience,
    p.money,
    p.bank,
    t.name as team_name,
    COUNT(DISTINCT dc.id) as total_captures,
    COUNT(DISTINCT ma.id) as total_missions,
    COUNT(DISTINCT ep.id) as total_events,
    COUNT(DISTINCT pa.id) as total_achievements
FROM players p
LEFT JOIN teams t ON p.team_id = t.id
LEFT JOIN district_captures dc ON p.id = dc.captured_by
LEFT JOIN mission_assignments ma ON p.id = ma.player_id AND ma.status = 'completed'
LEFT JOIN event_participants ep ON p.id = ep.player_id
LEFT JOIN player_achievements pa ON p.id = pa.player_id AND pa.completed = TRUE
GROUP BY p.id;

CREATE OR REPLACE VIEW `team_stats` AS
SELECT 
    t.id,
    t.name,
    t.leader_id,
    p.name as leader_name,
    t.current_members,
    t.total_captures,
    t.total_missions,
    t.total_events,
    COUNT(DISTINCT dc.id) as recent_captures,
    AVG(p.level) as avg_member_level
FROM teams t
LEFT JOIN players p ON t.leader_id = p.id
LEFT JOIN district_captures dc ON t.id = dc.team_id AND dc.captured_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
LEFT JOIN players pm ON t.id = pm.team_id
GROUP BY t.id;

-- Create stored procedures for common operations
DELIMITER //

CREATE PROCEDURE `GetPlayerProgress`(IN player_id INT)
BEGIN
    SELECT 
        p.name,
        p.level,
        p.experience,
        COUNT(DISTINCT dc.id) as captures,
        COUNT(DISTINCT ma.id) as missions_completed,
        COUNT(DISTINCT ep.id) as events_participated,
        COUNT(DISTINCT pa.id) as achievements_unlocked
    FROM players p
    LEFT JOIN district_captures dc ON p.id = dc.captured_by
    LEFT JOIN mission_assignments ma ON p.id = ma.player_id AND ma.status = 'completed'
    LEFT JOIN event_participants ep ON p.id = ep.player_id
    LEFT JOIN player_achievements pa ON p.id = pa.player_id AND pa.completed = TRUE
    WHERE p.id = player_id
    GROUP BY p.id;
END //

CREATE PROCEDURE `GetDistrictHistory`(IN district_id INT, IN days INT)
BEGIN
    SELECT 
        dc.captured_at,
        t.name as team_name,
        p.name as captured_by,
        dc.capture_time
    FROM district_captures dc
    JOIN teams t ON dc.team_id = t.id
    JOIN players p ON dc.captured_by = p.id
    WHERE dc.district_id = district_id
    AND dc.captured_at >= DATE_SUB(NOW(), INTERVAL days DAY)
    ORDER BY dc.captured_at DESC;
END //

CREATE PROCEDURE `GetTopPlayers`(IN limit_count INT)
BEGIN
    SELECT 
        p.name,
        p.level,
        p.experience,
        COUNT(DISTINCT dc.id) as captures,
        COUNT(DISTINCT ma.id) as missions_completed,
        COUNT(DISTINCT pa.id) as achievements_unlocked
    FROM players p
    LEFT JOIN district_captures dc ON p.id = dc.captured_by
    LEFT JOIN mission_assignments ma ON p.id = ma.player_id AND ma.status = 'completed'
    LEFT JOIN player_achievements pa ON p.id = pa.player_id AND pa.completed = TRUE
    GROUP BY p.id
    ORDER BY p.experience DESC, captures DESC
    LIMIT limit_count;
END //

DELIMITER ;

-- Create triggers for data integrity
DELIMITER //

CREATE TRIGGER `update_team_members_count` 
AFTER UPDATE ON `players`
FOR EACH ROW
BEGIN
    IF OLD.team_id != NEW.team_id THEN
        -- Decrease count for old team
        IF OLD.team_id IS NOT NULL THEN
            UPDATE teams SET current_members = current_members - 1 WHERE id = OLD.team_id;
        END IF;
        -- Increase count for new team
        IF NEW.team_id IS NOT NULL THEN
            UPDATE teams SET current_members = current_members + 1 WHERE id = NEW.team_id;
        END IF;
    END IF;
END //

CREATE TRIGGER `update_team_captures_count`
AFTER INSERT ON `district_captures`
FOR EACH ROW
BEGIN
    UPDATE teams SET total_captures = total_captures + 1 WHERE id = NEW.team_id;
END //

CREATE TRIGGER `update_team_missions_count`
AFTER UPDATE ON `mission_assignments`
FOR EACH ROW
BEGIN
    IF OLD.status != 'completed' AND NEW.status = 'completed' AND NEW.team_id IS NOT NULL THEN
        UPDATE teams SET total_missions = total_missions + 1 WHERE id = NEW.team_id;
    END IF;
END //

DELIMITER ;

-- Grant permissions (adjust as needed)
-- GRANT ALL PRIVILEGES ON district_zero.* TO 'district_zero'@'localhost';
-- FLUSH PRIVILEGES;

print_success "Database schema created successfully" 