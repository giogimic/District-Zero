-- Characters
CREATE TABLE IF NOT EXISTS characters (
    id SERIAL PRIMARY KEY,
    identifier VARCHAR(64) NOT NULL,
    name VARCHAR(64) NOT NULL,
    faction VARCHAR(32),
    gang_id INTEGER,
    xp INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    reputation INTEGER DEFAULT 0,
    cash INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Factions
CREATE TABLE IF NOT EXISTS factions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    type VARCHAR(32) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Gangs (player-created)
CREATE TABLE IF NOT EXISTS gangs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    color VARCHAR(16),
    owner_identifier VARCHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Gang Members
CREATE TABLE IF NOT EXISTS gang_members (
    id SERIAL PRIMARY KEY,
    gang_id INTEGER NOT NULL,
    character_id INTEGER NOT NULL,
    rank INTEGER DEFAULT 1,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Districts
CREATE TABLE IF NOT EXISTS districts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    center_x FLOAT,
    center_y FLOAT,
    center_z FLOAT,
    radius FLOAT,
    controlling_faction VARCHAR(32),
    last_event VARCHAR(32),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Missions
CREATE TABLE IF NOT EXISTS missions (
    id SERIAL PRIMARY KEY,
    type VARCHAR(32) NOT NULL,
    difficulty INTEGER DEFAULT 1,
    district_id INTEGER,
    assigned_to INTEGER,
    state VARCHAR(16) DEFAULT 'pending',
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);

-- Jobs
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    type VARCHAR(32) NOT NULL,
    character_id INTEGER,
    state VARCHAR(16) DEFAULT 'pending',
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);

-- Economy (transactions)
CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    character_id INTEGER,
    amount INTEGER,
    type VARCHAR(16),
    description VARCHAR(128),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    character_id INTEGER,
    item VARCHAR(64),
    amount INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Skills
CREATE TABLE IF NOT EXISTS skills (
    id SERIAL PRIMARY KEY,
    character_id INTEGER,
    skill VARCHAR(32),
    level INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 