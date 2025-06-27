# District Zero FiveM - Complete Documentation

## Table of Contents
1. [Overview](#overview)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Features](#features)
5. [API Reference](#api-reference)
6. [Usage Guide](#usage-guide)
7. [Troubleshooting](#troubleshooting)
8. [Development](#development)
9. [Security](#security)
10. [Performance](#performance)
11. [Contributing](#contributing)

## Overview

District Zero FiveM is a comprehensive district-based competitive gaming system for FiveM servers. It provides a complete framework for territory control, mission systems, team management, events, achievements, analytics, security, and performance optimization.

### Key Features
- **District Control System**: Capture and defend territories
- **Mission System**: Dynamic missions with rewards
- **Team System**: Team creation and management
- **Event System**: Special events and competitions
- **Achievement System**: Progress tracking and rewards
- **Analytics System**: Performance metrics and statistics
- **Security System**: Anti-cheat and protection
- **Performance Optimization**: Resource management and optimization
- **Modern UI**: React-based responsive interface
- **Integration System**: Seamless system coordination

### System Requirements
- FiveM Server (latest version)
- MySQL Database (5.7+ or 8.0+)
- Node.js 16+ (for UI development)
- 4GB+ RAM (recommended)
- 2+ CPU cores (recommended)

## Installation

### Prerequisites
1. **FiveM Server**: Ensure you have a working FiveM server
2. **Database**: Set up MySQL database
3. **Dependencies**: Install required resources

### Step-by-Step Installation

#### 1. Download and Extract
```bash
# Download the resource
git clone https://github.com/district-zero/fivem-mm.git
cd fivem-mm

# Extract to your resources folder
cp -r district-zero /path/to/your/fivem/server/resources/
```

#### 2. Database Setup
```sql
-- Create database
CREATE DATABASE district_zero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user (optional)
CREATE USER 'district_zero'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON district_zero.* TO 'district_zero'@'localhost';
FLUSH PRIVILEGES;
```

#### 3. Configuration
```bash
# Copy and edit configuration files
cp config/database.example.json config/database.json
cp config/districts.example.json config/districts.json
# ... repeat for other config files
```

#### 4. Server Configuration
Add to your `server.cfg`:
```cfg
# District Zero
ensure district-zero

# Dependencies
ensure mysql-async
ensure oxmysql
ensure es_extended  # if using ESX
ensure qb-core      # if using QBCore
```

#### 5. Start the Resource
```bash
# Restart your FiveM server
# Or use the console command:
restart district-zero
```

## Configuration

### Database Configuration
```json
{
  "type": "mysql",
  "host": "localhost",
  "port": 3306,
  "database": "district_zero",
  "username": "root",
  "password": "",
  "connectionLimit": 10,
  "timeout": 5000
}
```

### Districts Configuration
```json
{
  "enabled": true,
  "maxDistricts": 10,
  "captureTime": 300,
  "captureRadius": 50.0,
  "rewardMultiplier": 1.0,
  "respawnTime": 60,
  "maxPlayersPerDistrict": 10
}
```

### Missions Configuration
```json
{
  "enabled": true,
  "maxActiveMissions": 5,
  "missionTimeout": 1800,
  "difficultyScaling": true,
  "rewardScaling": true,
  "maxMissionsPerPlayer": 3
}
```

### Teams Configuration
```json
{
  "enabled": true,
  "maxTeamSize": 8,
  "minTeamSize": 2,
  "teamCreationCost": 1000,
  "maxTeams": 20,
  "teamNameMaxLength": 20
}
```

### Security Configuration
```json
{
  "enabled": true,
  "antiCheatLevel": "medium",
  "rateLimitEnabled": true,
  "maxRequestsPerMinute": 100,
  "banDuration": 3600,
  "whitelistEnabled": false
}
```

## Features

### District Control System
- **Territory Capture**: Players can capture districts by staying in the area
- **Ownership Tracking**: Real-time tracking of district ownership
- **Rewards**: District-specific bonuses and rewards
- **Defense Mechanics**: Team-based district defense

### Mission System
- **Dynamic Missions**: Automatically generated missions
- **Mission Types**: Capture, defend, escort, delivery missions
- **Difficulty Scaling**: Missions scale with player level
- **Rewards**: Mission completion rewards and bonuses

### Team System
- **Team Creation**: Players can create and join teams
- **Team Management**: Team leader controls and permissions
- **Team Statistics**: Team performance tracking
- **Team Coordination**: Team-based features and communication

### Event System
- **Special Events**: Scheduled and dynamic events
- **Event Types**: Capture events, team battles, competitions
- **Event Rewards**: Special rewards for event participation
- **Event Management**: Admin controls for event creation

### Achievement System
- **Achievement Types**: Progress-based and milestone achievements
- **Achievement Tracking**: Automatic progress tracking
- **Achievement Rewards**: Unlock rewards and bonuses
- **Leaderboards**: Achievement-based leaderboards

### Analytics System
- **Player Analytics**: Individual player statistics
- **Team Analytics**: Team performance metrics
- **District Analytics**: District control statistics
- **Mission Analytics**: Mission completion rates

### Security System
- **Anti-Cheat**: Detection and prevention of cheating
- **Rate Limiting**: Request rate limiting
- **Input Validation**: Server-side input validation
- **Security Logging**: Comprehensive security logging

## API Reference

### Server-Side Exports

#### Core Systems
```lua
-- Districts
local districts = exports["district-zero"]:GetDistrictsSystem()
local allDistricts = districts.GetDistricts()
local district = districts.GetDistrict(id)
local success = districts.CaptureDistrict(id, teamId)

-- Missions
local missions = exports["district-zero"]:GetMissionsSystem()
local allMissions = missions.GetMissions()
local mission = missions.GetMission(id)
local newMission = missions.CreateMission(data)
local success = missions.CompleteMission(id, playerId)

-- Teams
local teams = exports["district-zero"]:GetTeamsSystem()
local allTeams = teams.GetTeams()
local team = teams.GetTeam(id)
local newTeam = teams.CreateTeam(data)
local success = teams.JoinTeam(teamId, playerId)

-- Events
local events = exports["district-zero"]:GetEventsSystem()
local allEvents = events.GetEvents()
local event = events.GetEvent(id)
local success = events.StartEvent(id)

-- Achievements
local achievements = exports["district-zero"]:GetAchievementsSystem()
local allAchievements = achievements.GetAchievements()
local playerAchievements = achievements.GetPlayerAchievements(playerId)
local success = achievements.UnlockAchievement(playerId, achievementId)
```

#### Advanced Systems
```lua
-- Analytics
local analytics = exports["district-zero"]:GetAnalyticsSystem()
local allAnalytics = analytics.GetAnalytics()
local playerAnalytics = analytics.GetPlayerAnalytics(playerId)
local success = analytics.TrackEvent(event, data)

-- Security
local security = exports["district-zero"]:GetSecuritySystem()
local securityStatus = security.GetSecurityStatus()
local isSecure = security.CheckPlayerSecurity(playerId)
local success = security.ReportViolation(playerId, violation)

-- Performance
local performance = exports["district-zero"]:GetPerformanceSystem()
local metrics = performance.GetPerformanceMetrics()
local success = performance.OptimizePerformance()

-- Integration
local integration = exports["district-zero"]:GetIntegrationSystem()
local status = integration.GetSystemStatus()
local health = integration.GetIntegrationHealth()
```

#### Unified API
```lua
-- Get unified API
local api = exports["district-zero"]:GetUnifiedAPI()

-- Use unified API
local districts = api.GetDistricts()
local missions = api.GetMissions()
local teams = api.GetTeams()
local events = api.GetEvents()
local achievements = api.GetAchievements()
local analytics = api.GetAnalytics()
local security = api.GetSecurityStatus()
local performance = api.GetPerformanceMetrics()
```

### Client-Side Exports
```lua
-- UI
local ui = exports["district-zero"]:GetUI()
ui.ShowInterface()
ui.HideInterface()
ui.UpdateData(data)

-- Events
local events = exports["district-zero"]:GetClientEvents()
events.RegisterCallback(event, callback)
events.TriggerEvent(event, data)

-- Performance
local performance = exports["district-zero"]:GetClientPerformance()
performance.GetMetrics()
performance.Optimize()
```

## Usage Guide

### Player Commands
```bash
# District commands
/dc - Show district control interface
/capture <district_id> - Attempt to capture a district
/leave <district_id> - Leave a district

# Mission commands
/missions - Show available missions
/accept <mission_id> - Accept a mission
/complete <mission_id> - Complete a mission

# Team commands
/team create <name> - Create a team
/team join <team_id> - Join a team
/team leave - Leave current team
/team info - Show team information

# Event commands
/events - Show active events
/join <event_id> - Join an event
/leave <event_id> - Leave an event

# Achievement commands
/achievements - Show achievements
/progress - Show achievement progress
```

### Admin Commands
```bash
# System management
/system_status - Show system status
/system_health - Show system health
/system_sync - Sync all systems
/system_test - Test system integration

# Configuration
/config_reload [config_name] - Reload configuration
/config_list - List all configurations
/config_show <config_name> - Show configuration
/config_reset <config_name> - Reset configuration
/config_export <config_name> - Export configuration

# District management
/district_create <name> <coords> - Create district
/district_delete <id> - Delete district
/district_reset <id> - Reset district ownership

# Mission management
/mission_create <type> <data> - Create mission
/mission_delete <id> - Delete mission
/mission_start <id> - Start mission

# Team management
/team_create <name> <leader> - Create team
/team_delete <id> - Delete team
/team_reset <id> - Reset team

# Event management
/event_create <type> <data> - Create event
/event_delete <id> - Delete event
/event_start <id> - Start event

# Analytics
/analytics_show - Show analytics
/analytics_export - Export analytics
/analytics_reset - Reset analytics

# Security
/security_status - Show security status
/security_check <player_id> - Check player security
/security_ban <player_id> <duration> - Ban player
/security_unban <player_id> - Unban player

# Performance
/performance_show - Show performance metrics
/performance_optimize - Optimize performance
/performance_reset - Reset performance data

# Deployment
/deploy <version> [config_file] - Deploy new version
/rollback - Rollback to previous version
/deployment_status - Show deployment status
/deployment_history - Show deployment history

# Release
/create_release <version> [type] - Create release
/release_status - Show release status
/changelog - Show changelog
/release_notes - Show release notes

# Error handling
/error_show - Show error statistics
/error_clear - Clear error logs
/error_export - Export error logs
```

## Troubleshooting

### Common Issues

#### Resource Won't Start
**Problem**: Resource fails to start
**Solution**:
1. Check dependencies are installed
2. Verify database connection
3. Check configuration files
4. Review server console for errors

#### Database Connection Issues
**Problem**: Cannot connect to database
**Solution**:
1. Verify database credentials
2. Check database server is running
3. Ensure database exists
4. Check network connectivity

#### Performance Issues
**Problem**: Server lag or poor performance
**Solution**:
1. Check resource usage
2. Optimize database queries
3. Reduce concurrent operations
4. Monitor system resources

#### UI Not Loading
**Problem**: Interface doesn't appear
**Solution**:
1. Check UI files are present
2. Verify client-side scripts
3. Check browser console for errors
4. Restart client

#### Security Violations
**Problem**: False positive security alerts
**Solution**:
1. Review security configuration
2. Adjust sensitivity settings
3. Whitelist legitimate players
4. Update security rules

### Error Codes

#### Database Errors
- `DB001`: Connection failed
- `DB002`: Query failed
- `DB003`: Table not found
- `DB004`: Permission denied

#### System Errors
- `SYS001`: Resource not found
- `SYS002`: Configuration error
- `SYS003`: Initialization failed
- `SYS004`: Dependency missing

#### Security Errors
- `SEC001`: Rate limit exceeded
- `SEC002`: Invalid input
- `SEC003`: Unauthorized access
- `SEC004`: Cheat detected

### Debug Mode
Enable debug mode in configuration:
```json
{
  "debug": {
    "enabled": true,
    "level": "verbose",
    "logToFile": true
  }
}
```

## Development

### Project Structure
```
district-zero/
├── server/           # Server-side scripts
├── client/           # Client-side scripts
├── shared/           # Shared scripts
├── ui/               # React UI components
├── config/           # Configuration files
├── data/             # Data files
├── docs/             # Documentation
├── tests/            # Test files
└── exports/          # Export files
```

### Development Setup
```bash
# Clone repository
git clone https://github.com/district-zero/fivem-mm.git
cd fivem-mm

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

### Testing
```bash
# Run unit tests
npm test

# Run integration tests
npm run test:integration

# Run performance tests
npm run test:performance

# Run security tests
npm run test:security
```

### Code Style
- Use ESLint for JavaScript/TypeScript
- Follow Lua coding standards
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for new features

## Security

### Security Features
- **Anti-Cheat**: Detection and prevention of cheating
- **Input Validation**: Server-side validation of all inputs
- **Rate Limiting**: Request rate limiting to prevent abuse
- **Access Control**: Role-based access control
- **Audit Logging**: Comprehensive security logging

### Security Best Practices
1. **Server-Side Validation**: Always validate on server
2. **Input Sanitization**: Sanitize all user inputs
3. **Rate Limiting**: Implement rate limiting
4. **Access Control**: Use proper access controls
5. **Security Monitoring**: Monitor for security issues
6. **Regular Updates**: Keep security systems updated

### Security Configuration
```json
{
  "security": {
    "enabled": true,
    "antiCheatLevel": "high",
    "rateLimitEnabled": true,
    "maxRequestsPerMinute": 50,
    "banDuration": 3600,
    "whitelistEnabled": true,
    "auditLogging": true
  }
}
```

## Performance

### Performance Optimization
- **Database Optimization**: Optimized queries and indexing
- **Caching**: Implement caching for frequently accessed data
- **Resource Management**: Efficient resource usage
- **Load Balancing**: Distribute load across systems
- **Monitoring**: Real-time performance monitoring

### Performance Configuration
```json
{
  "performance": {
    "enabled": true,
    "optimizationLevel": "high",
    "cacheEnabled": true,
    "cacheSize": 2000,
    "gcInterval": 300000,
    "memoryLimit": 70
  }
}
```

### Performance Monitoring
- **Resource Usage**: Monitor CPU and memory usage
- **Database Performance**: Monitor query performance
- **Network Performance**: Monitor network latency
- **Client Performance**: Monitor client-side performance

## Contributing

### Contributing Guidelines
1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Write tests**
5. **Submit a pull request**

### Code of Conduct
- Be respectful and inclusive
- Follow coding standards
- Write clear documentation
- Test your changes
- Review others' code

### Development Workflow
1. **Issue Creation**: Create an issue for new features
2. **Branch Creation**: Create a feature branch
3. **Development**: Implement the feature
4. **Testing**: Write and run tests
5. **Documentation**: Update documentation
6. **Review**: Submit for review
7. **Merge**: Merge after approval

### Contact
- **GitHub**: https://github.com/district-zero/fivem-mm
- **Issues**: https://github.com/district-zero/fivem-mm/issues
- **Discord**: [Join our Discord](https://discord.gg/district-zero)

---

**Version**: 1.0.0  
**Last Updated**: 2024-01-XX  
**License**: MIT License 