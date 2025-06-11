-- Create migrations table
CREATE TABLE IF NOT EXISTS dz_migrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create factions table
CREATE TABLE IF NOT EXISTS dz_factions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    level INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create faction members table
CREATE TABLE IF NOT EXISTS dz_faction_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    faction_id INT NOT NULL,
    citizenid VARCHAR(50) NOT NULL,
    role ENUM('leader', 'officer', 'member') DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (faction_id) REFERENCES dz_factions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_member (faction_id, citizenid)
);

-- Create districts table
CREATE TABLE IF NOT EXISTS dz_districts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    x1 FLOAT NOT NULL,
    y1 FLOAT NOT NULL,
    z1 FLOAT NOT NULL,
    x2 FLOAT NOT NULL,
    y2 FLOAT NOT NULL,
    z2 FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create events table
CREATE TABLE IF NOT EXISTS dz_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    district_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status ENUM('scheduled', 'active', 'completed') DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (district_id) REFERENCES dz_districts(id) ON DELETE CASCADE
);

-- Create district control table
CREATE TABLE IF NOT EXISTS dz_district_control (
    id INT AUTO_INCREMENT PRIMARY KEY,
    district_id INT NOT NULL,
    faction_id INT NOT NULL,
    influence FLOAT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (district_id) REFERENCES dz_districts(id) ON DELETE CASCADE,
    FOREIGN KEY (faction_id) REFERENCES dz_factions(id) ON DELETE CASCADE,
    UNIQUE KEY unique_district (district_id)
); 