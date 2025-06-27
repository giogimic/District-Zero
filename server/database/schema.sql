-- District Zero Schema

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS dz_crime_reports;
DROP TABLE IF EXISTS dz_crimes;
DROP TABLE IF EXISTS dz_player_equipment;
DROP TABLE IF EXISTS dz_equipment;
DROP TABLE IF EXISTS dz_ability_progress;
DROP TABLE IF EXISTS dz_mission_progress;
DROP TABLE IF EXISTS dz_faction_members;
DROP TABLE IF EXISTS dz_players;
DROP TABLE IF EXISTS dz_abilities;
DROP TABLE IF EXISTS dz_missions;
DROP TABLE IF EXISTS dz_factions;
DROP TABLE IF EXISTS dz_districts;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Create base tables first (no foreign key dependencies)
CREATE TABLE dz_districts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    owner INT,
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    rewards JSON,
    crime_level INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_owner (owner),
    INDEX idx_status (status),
    INDEX idx_crime_level (crime_level)
);

CREATE TABLE dz_factions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    leader INT,
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    rewards JSON,
    reputation INT DEFAULT 0,
    territory_control JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_leader (leader),
    INDEX idx_status (status),
    INDEX idx_reputation (reputation)
);

CREATE TABLE dz_missions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    type ENUM('main', 'side', 'daily', 'weekly') DEFAULT 'side',
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    objectives JSON,
    rewards JSON,
    difficulty ENUM('easy', 'medium', 'hard', 'extreme') DEFAULT 'medium',
    time_limit INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_difficulty (difficulty)
);

CREATE TABLE dz_abilities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    type ENUM('passive', 'active', 'ultimate') DEFAULT 'active',
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    effects JSON,
    cooldown INT DEFAULT 0,
    energy_cost INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_status (status)
);

CREATE TABLE dz_equipment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    type ENUM('weapon', 'armor', 'gadget', 'vehicle') DEFAULT 'gadget',
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    stats JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_status (status)
);

CREATE TABLE dz_crimes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    type ENUM('theft', 'assault', 'drugs', 'organized') DEFAULT 'theft',
    severity ENUM('low', 'medium', 'high', 'extreme') DEFAULT 'medium',
    rewards JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_severity (severity)
);

-- Create player-related tables
CREATE TABLE dz_players (
    id INT PRIMARY KEY AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    faction_id INT,
    rank INT DEFAULT 1,
    experience INT DEFAULT 0,
    level INT DEFAULT 1,
    metadata JSON,
    reputation INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_citizenid (citizenid),
    INDEX idx_faction (faction_id),
    INDEX idx_reputation (reputation)
);

-- Create relationship tables
CREATE TABLE dz_faction_members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    faction_id INT NOT NULL,
    player_id INT NOT NULL,
    rank INT DEFAULT 1,
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_faction_player (faction_id, player_id),
    INDEX idx_player (player_id)
);

CREATE TABLE dz_mission_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mission_id INT NOT NULL,
    player_id INT NOT NULL,
    status ENUM('not_started', 'in_progress', 'completed', 'failed') DEFAULT 'not_started',
    progress JSON,
    started_at DATETIME NULL,
    completed_at DATETIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_mission_player (mission_id, player_id),
    INDEX idx_player (player_id)
);

CREATE TABLE dz_ability_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ability_id INT NOT NULL,
    player_id INT NOT NULL,
    status ENUM('locked', 'unlocked', 'mastered') DEFAULT 'locked',
    level INT DEFAULT 0,
    experience INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_ability_player (ability_id, player_id),
    INDEX idx_player (player_id)
);

CREATE TABLE dz_player_equipment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    equipment_id INT NOT NULL,
    status ENUM('equipped', 'unequipped', 'broken') DEFAULT 'unequipped',
    durability INT DEFAULT 100,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_player_equipment (player_id, equipment_id),
    INDEX idx_player (player_id)
);

CREATE TABLE dz_crime_reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    crime_id INT NOT NULL,
    reporter_id INT NOT NULL,
    location JSON,
    description TEXT,
    status ENUM('reported', 'investigating', 'resolved', 'false_alarm') DEFAULT 'reported',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_crime (crime_id),
    INDEX idx_reporter (reporter_id),
    INDEX idx_status (status)
);

-- Add foreign key constraints
ALTER TABLE dz_districts
ADD CONSTRAINT fk_district_owner
FOREIGN KEY (owner) REFERENCES dz_players(id)
ON DELETE SET NULL;

ALTER TABLE dz_factions
ADD CONSTRAINT fk_faction_leader
FOREIGN KEY (leader) REFERENCES dz_players(id)
ON DELETE SET NULL;

ALTER TABLE dz_players
ADD CONSTRAINT fk_player_faction
FOREIGN KEY (faction_id) REFERENCES dz_factions(id)
ON DELETE SET NULL;

ALTER TABLE dz_faction_members
ADD CONSTRAINT fk_member_faction
FOREIGN KEY (faction_id) REFERENCES dz_factions(id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_member_player
FOREIGN KEY (player_id) REFERENCES dz_players(id)
ON DELETE CASCADE;

ALTER TABLE dz_mission_progress
ADD CONSTRAINT fk_progress_mission
FOREIGN KEY (mission_id) REFERENCES dz_missions(id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_progress_player
FOREIGN KEY (player_id) REFERENCES dz_players(id)
ON DELETE CASCADE;

ALTER TABLE dz_ability_progress
ADD CONSTRAINT fk_ability_progress_ability
FOREIGN KEY (ability_id) REFERENCES dz_abilities(id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_ability_progress_player
FOREIGN KEY (player_id) REFERENCES dz_players(id)
ON DELETE CASCADE;

ALTER TABLE dz_player_equipment
ADD CONSTRAINT fk_player_equipment_player
FOREIGN KEY (player_id) REFERENCES dz_players(id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_player_equipment_equipment
FOREIGN KEY (equipment_id) REFERENCES dz_equipment(id)
ON DELETE CASCADE;

ALTER TABLE dz_crime_reports
ADD CONSTRAINT fk_crime_report_crime
FOREIGN KEY (crime_id) REFERENCES dz_crimes(id)
ON DELETE CASCADE,
ADD CONSTRAINT fk_crime_report_reporter
FOREIGN KEY (reporter_id) REFERENCES dz_players(id)
ON DELETE CASCADE;

-- Insert default data in correct order
INSERT INTO dz_districts (name, description, status, crime_level) VALUES
('Downtown', 'The heart of the city, where corruption runs deep', 'active', 75),
('Industrial', 'Abandoned factories and warehouses, perfect for criminal operations', 'active', 85),
('Residential', 'Quiet neighborhoods hiding dark secrets', 'active', 65),
('Docks', 'Smuggling hub and criminal hideout', 'active', 90),
('Suburbs', 'Seemingly peaceful area with hidden criminal networks', 'active', 55);

INSERT INTO dz_factions (name, description, status, reputation) VALUES
('Vigilantes', 'Justice seekers operating outside the law', 'active', 100),
('Street Gangs', 'Local criminal organizations', 'active', -50),
('Corporations', 'Corrupt business entities', 'active', -75),
('Mercenaries', 'For-hire operatives', 'active', 0),
('Hackers', 'Digital vigilantes and criminals', 'active', 25);

INSERT INTO dz_missions (name, description, type, status, difficulty) VALUES
('Night Patrol', 'Patrol the streets and stop crimes in progress', 'main', 'active', 'medium'),
('Evidence Gathering', 'Collect evidence of criminal activities', 'side', 'active', 'easy'),
('Gang Takedown', 'Take down a local gang operation', 'main', 'active', 'hard'),
('Corruption Expose', 'Uncover corporate corruption', 'main', 'active', 'extreme'),
('Tech Support', 'Help citizens with tech-related issues', 'side', 'active', 'easy'),
('Vigilante Training', 'Complete advanced combat training', 'side', 'active', 'medium');

INSERT INTO dz_abilities (name, description, type, status, cooldown, energy_cost) VALUES
('Combat Mastery', 'Enhanced combat abilities', 'passive', 'active', 0, 0),
('Stealth Mode', 'Temporary invisibility', 'active', 'active', 300, 50),
('Tech Override', 'Hack into nearby systems', 'active', 'active', 180, 30),
('Vigilante Sense', 'Detect nearby crimes', 'passive', 'active', 0, 0),
('Justice Strike', 'Powerful takedown move', 'ultimate', 'active', 600, 100);

INSERT INTO dz_equipment (name, description, type, status, stats) VALUES
('Grappling Hook', 'Mobility tool for vertical movement', 'gadget', 'active', '{"range": 50, "cooldown": 10}'),
('Combat Armor', 'Protective gear for vigilantes', 'armor', 'active', '{"defense": 75, "mobility": -10}'),
('Stun Baton', 'Non-lethal takedown weapon', 'weapon', 'active', '{"damage": 25, "stun": 5}'),
('Night Vision Goggles', 'Enhanced night vision', 'gadget', 'active', '{"vision": 100, "battery": 120}'),
('Vigilante Bike', 'High-speed pursuit vehicle', 'vehicle', 'active', '{"speed": 150, "handling": 80}');

INSERT INTO dz_crimes (name, description, type, severity, rewards) VALUES
('Armed Robbery', 'Robbery with weapons involved', 'theft', 'high', '{"experience": 100, "reputation": 10}'),
('Drug Trafficking', 'Illegal drug distribution', 'drugs', 'high', '{"experience": 150, "reputation": 15}'),
('Assault', 'Violent attack on citizens', 'assault', 'medium', '{"experience": 75, "reputation": 8}'),
('Corporate Fraud', 'Large-scale financial crime', 'organized', 'extreme', '{"experience": 200, "reputation": 20}'),
('Gang Activity', 'Organized criminal operations', 'organized', 'high', '{"experience": 125, "reputation": 12}');

INSERT INTO dz_players (citizenid, faction_id, rank, experience, level, metadata) VALUES
('123456789', 1, 1, 0, 1, '{"name": "John Doe", "age": 30}'),
('987654321', 2, 1, 0, 1, '{"name": "Jane Smith", "age": 25}'),
('555555555', 3, 1, 0, 1, '{"name": "Bob Johnson", "age": 40}'),
('777777777', 4, 1, 0, 1, '{"name": "Alice Brown", "age": 28}'),
('888888888', 5, 1, 0, 1, '{"name": "Charlie Davis", "age": 35}');

INSERT INTO dz_faction_members (faction_id, player_id, rank) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1);

INSERT INTO dz_mission_progress (mission_id, player_id, status, progress) VALUES
(1, 1, 'completed', '{"progress": 100}'),
(2, 2, 'completed', '{"progress": 100}'),
(3, 3, 'completed', '{"progress": 100}'),
(4, 4, 'completed', '{"progress": 100}'),
(5, 5, 'completed', '{"progress": 100}');

INSERT INTO dz_ability_progress (ability_id, player_id, status, level, experience) VALUES
(1, 1, 'mastered', 5, 1000),
(2, 2, 'mastered', 5, 1000),
(3, 3, 'mastered', 5, 1000),
(4, 4, 'mastered', 5, 1000),
(5, 5, 'mastered', 5, 1000);

INSERT INTO dz_player_equipment (player_id, equipment_id, status, durability) VALUES
(1, 1, 'equipped', 100),
(2, 2, 'equipped', 100),
(3, 3, 'equipped', 100),
(4, 4, 'equipped', 100),
(5, 5, 'equipped', 100);

-- Player Statistics Table
CREATE TABLE IF NOT EXISTS player_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id VARCHAR(50) NOT NULL,
    player_name VARCHAR(100),
    team_type ENUM('pvp', 'pve', 'neutral') DEFAULT 'neutral',
    total_captures INT DEFAULT 0,
    total_missions INT DEFAULT 0,
    total_eliminations INT DEFAULT 0,
    total_assists INT DEFAULT 0,
    total_team_events INT DEFAULT 0,
    total_points INT DEFAULT 0,
    total_playtime INT DEFAULT 0, -- in seconds
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_player (player_id),
    INDEX idx_team_type (team_type),
    INDEX idx_total_points (total_points),
    INDEX idx_last_active (last_active)
);

-- District Control History Table
CREATE TABLE IF NOT EXISTS district_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    district_id VARCHAR(50) NOT NULL,
    district_name VARCHAR(100),
    controlling_team ENUM('pvp', 'pve', 'neutral') NOT NULL,
    previous_team ENUM('pvp', 'pve', 'neutral'),
    capture_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    capture_duration INT DEFAULT 0, -- in seconds
    capture_method ENUM('control_point', 'influence', 'event', 'admin') DEFAULT 'control_point',
    captured_by VARCHAR(50), -- player_id who initiated capture
    influence_pvp INT DEFAULT 0,
    influence_pve INT DEFAULT 0,
    INDEX idx_district_id (district_id),
    INDEX idx_controlling_team (controlling_team),
    INDEX idx_capture_time (capture_time),
    INDEX idx_captured_by (captured_by)
);

-- Control Point Capture History Table
CREATE TABLE IF NOT EXISTS control_point_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    district_id VARCHAR(50) NOT NULL,
    point_id VARCHAR(50) NOT NULL,
    point_name VARCHAR(100),
    capturing_team ENUM('pvp', 'pve') NOT NULL,
    capture_start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    capture_end_time TIMESTAMP NULL,
    capture_duration INT DEFAULT 0, -- in seconds
    capture_success BOOLEAN DEFAULT FALSE,
    captured_by VARCHAR(50), -- player_id who completed capture
    participants JSON, -- Array of player_ids who participated
    INDEX idx_district_point (district_id, point_id),
    INDEX idx_capturing_team (capturing_team),
    INDEX idx_capture_start (capture_start_time),
    INDEX idx_captured_by (captured_by)
);

-- Mission Completion Logs Table
CREATE TABLE IF NOT EXISTS mission_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mission_id VARCHAR(100) NOT NULL,
    player_id VARCHAR(50) NOT NULL,
    mission_type VARCHAR(50) NOT NULL,
    mission_title VARCHAR(200),
    mission_difficulty ENUM('EASY', 'MEDIUM', 'HARD', 'EXPERT') DEFAULT 'EASY',
    district_id VARCHAR(50),
    objectives JSON, -- Mission objectives and completion status
    rewards JSON, -- Rewards given
    completion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration INT DEFAULT 0, -- in seconds
    success BOOLEAN DEFAULT TRUE,
    progress_data JSON, -- Detailed progress tracking
    INDEX idx_mission_id (mission_id),
    INDEX idx_player_id (player_id),
    INDEX idx_mission_type (mission_type),
    INDEX idx_completion_time (completion_time),
    INDEX idx_district_id (district_id)
);

-- Team Performance Analytics Table
CREATE TABLE IF NOT EXISTS team_analytics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    team_type ENUM('pvp', 'pve') NOT NULL,
    date DATE NOT NULL,
    total_members INT DEFAULT 0,
    total_captures INT DEFAULT 0,
    total_missions INT DEFAULT 0,
    total_eliminations INT DEFAULT 0,
    total_assists INT DEFAULT 0,
    total_team_events INT DEFAULT 0,
    total_points INT DEFAULT 0,
    average_playtime INT DEFAULT 0, -- in seconds
    district_control_time INT DEFAULT 0, -- in seconds
    events_created INT DEFAULT 0,
    events_completed INT DEFAULT 0,
    events_failed INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_team_date (team_type, date),
    INDEX idx_team_type (team_type),
    INDEX idx_date (date),
    INDEX idx_total_points (total_points)
);

-- Team Events Table
CREATE TABLE IF NOT EXISTS team_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    team_type ENUM('pvp', 'pve') NOT NULL,
    creator_id VARCHAR(50),
    event_data JSON,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    duration INT DEFAULT 0, -- in seconds
    status ENUM('active', 'completed', 'failed', 'cancelled') DEFAULT 'active',
    participants JSON, -- Array of participant data
    rewards_distributed JSON, -- Rewards given to participants
    INDEX idx_event_id (event_id),
    INDEX idx_team_type (team_type),
    INDEX idx_event_type (event_type),
    INDEX idx_start_time (start_time),
    INDEX idx_status (status)
);

-- Player Session Logs Table
CREATE TABLE IF NOT EXISTS session_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id VARCHAR(50) NOT NULL,
    session_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_end TIMESTAMP NULL,
    session_duration INT DEFAULT 0, -- in seconds
    team_type ENUM('pvp', 'pve', 'neutral'),
    districts_visited JSON, -- Array of district IDs visited
    activities_performed JSON, -- Array of activities during session
    INDEX idx_player_id (player_id),
    INDEX idx_session_start (session_start),
    INDEX idx_team_type (team_type)
);

-- District Influence History Table
CREATE TABLE IF NOT EXISTS district_influence_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    district_id VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    influence_pvp INT DEFAULT 0,
    influence_pve INT DEFAULT 0,
    influence_neutral INT DEFAULT 0,
    total_influence INT DEFAULT 0,
    change_reason VARCHAR(100), -- Reason for influence change
    INDEX idx_district_id (district_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_influence_pvp (influence_pvp),
    INDEX idx_influence_pve (influence_pve)
);

-- Achievement Tracking Table
CREATE TABLE IF NOT EXISTS achievements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id VARCHAR(50) NOT NULL,
    achievement_id VARCHAR(50) NOT NULL,
    achievement_name VARCHAR(100) NOT NULL,
    achievement_description TEXT,
    achievement_type VARCHAR(50),
    progress_current INT DEFAULT 0,
    progress_required INT DEFAULT 1,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_player_achievement (player_id, achievement_id),
    INDEX idx_player_id (player_id),
    INDEX idx_achievement_id (achievement_id),
    INDEX idx_completed (completed)
);

-- System Configuration Table
CREATE TABLE IF NOT EXISTS system_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT,
    config_type ENUM('string', 'integer', 'float', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_config_key (config_key),
    INDEX idx_config_key (config_key)
);

-- Insert default system configuration
INSERT IGNORE INTO system_config (config_key, config_value, config_type, description) VALUES
('team_balance_threshold', '5', 'integer', 'Maximum difference between team sizes'),
('team_switch_cooldown', '300', 'integer', 'Team switch cooldown in seconds'),
('team_event_interval', '600', 'integer', 'Random team event interval in seconds'),
('capture_time', '60', 'integer', 'Control point capture time in seconds'),
('mission_cooldown', '300', 'integer', 'Mission cooldown in seconds'),
('influence_decay_rate', '0.1', 'float', 'Influence decay rate per minute'),
('max_team_size', '50', 'integer', 'Maximum team size'),
('team_bonus_multiplier', '1.2', 'float', 'Team activity bonus multiplier');

-- Create views for common queries
CREATE OR REPLACE VIEW player_leaderboard AS
SELECT 
    ps.player_id,
    ps.player_name,
    ps.team_type,
    ps.total_captures,
    ps.total_missions,
    ps.total_eliminations,
    ps.total_assists,
    ps.total_team_events,
    ps.total_points,
    ps.total_playtime,
    ps.last_active,
    ROW_NUMBER() OVER (PARTITION BY ps.team_type ORDER BY ps.total_points DESC) as team_rank,
    ROW_NUMBER() OVER (ORDER BY ps.total_points DESC) as global_rank
FROM player_stats ps
WHERE ps.team_type IN ('pvp', 'pve');

CREATE OR REPLACE VIEW district_control_summary AS
SELECT 
    dh.district_id,
    dh.district_name,
    dh.controlling_team,
    dh.capture_time as last_capture,
    TIMESTAMPDIFF(SECOND, dh.capture_time, NOW()) as control_duration,
    COUNT(*) as total_captures
FROM district_history dh
WHERE dh.capture_time = (
    SELECT MAX(capture_time) 
    FROM district_history dh2 
    WHERE dh2.district_id = dh.district_id
)
GROUP BY dh.district_id, dh.district_name, dh.controlling_team, dh.capture_time;

CREATE OR REPLACE VIEW team_performance_summary AS
SELECT 
    ta.team_type,
    ta.date,
    ta.total_members,
    ta.total_captures,
    ta.total_missions,
    ta.total_eliminations,
    ta.total_assists,
    ta.total_team_events,
    ta.total_points,
    ta.average_playtime,
    ta.district_control_time,
    ta.events_created,
    ta.events_completed,
    ta.events_failed,
    ROUND(ta.events_completed / NULLIF(ta.events_created, 0) * 100, 2) as event_success_rate
FROM team_analytics ta
ORDER BY ta.date DESC, ta.team_type; 