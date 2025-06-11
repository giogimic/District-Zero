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