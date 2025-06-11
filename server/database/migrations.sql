-- District Zero Database Migration

-- Drop existing tables if they exist
DROP TABLE IF EXISTS dz_districts;
DROP TABLE IF EXISTS dz_factions;
DROP TABLE IF EXISTS dz_missions;
DROP TABLE IF EXISTS dz_abilities;
DROP TABLE IF EXISTS dz_players;
DROP TABLE IF EXISTS dz_faction_members;
DROP TABLE IF EXISTS dz_mission_progress;
DROP TABLE IF EXISTS dz_ability_progress;

-- Create districts table
CREATE TABLE dz_districts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    owner INT,
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    rewards JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_owner (owner),
    INDEX idx_status (status)
);

-- Create factions table
CREATE TABLE dz_factions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    leader INT,
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    rewards JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_leader (leader),
    INDEX idx_status (status)
);

-- Create missions table
CREATE TABLE dz_missions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    type ENUM('main', 'side', 'daily', 'weekly') DEFAULT 'side',
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    objectives JSON,
    rewards JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_status (status)
);

-- Create abilities table
CREATE TABLE dz_abilities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    type ENUM('passive', 'active', 'ultimate') DEFAULT 'active',
    status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
    requirements JSON,
    effects JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_status (status)
);

-- Create players table
CREATE TABLE dz_players (
    id INT PRIMARY KEY AUTO_INCREMENT,
    citizenid VARCHAR(50) NOT NULL,
    faction_id INT,
    rank INT DEFAULT 1,
    experience INT DEFAULT 0,
    level INT DEFAULT 1,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_citizenid (citizenid),
    INDEX idx_faction (faction_id)
);

-- Create faction members table
CREATE TABLE dz_faction_members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    faction_id INT NOT NULL,
    player_id INT NOT NULL,
    rank INT DEFAULT 1,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_faction_player (faction_id, player_id),
    INDEX idx_player (player_id)
);

-- Create mission progress table
CREATE TABLE dz_mission_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mission_id INT NOT NULL,
    player_id INT NOT NULL,
    status ENUM('not_started', 'in_progress', 'completed', 'failed') DEFAULT 'not_started',
    progress JSON,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_mission_player (mission_id, player_id),
    INDEX idx_player (player_id)
);

-- Create ability progress table
CREATE TABLE dz_ability_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ability_id INT NOT NULL,
    player_id INT NOT NULL,
    status ENUM('locked', 'unlocked', 'mastered') DEFAULT 'locked',
    level INT DEFAULT 0,
    experience INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_ability_player (ability_id, player_id),
    INDEX idx_player (player_id)
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