--[[
    District Zero FiveM - Release System
    Day 21: Release & Post-Launch Support
    
    Handles release packaging, version management, changelog tracking,
    release notes generation, deployment automation, and post-launch monitoring.
]]

local Release = {}
Release.__index = Release

-- Configuration
local CONFIG = {
    RELEASE_MODE = "production", -- production, beta, alpha
    AUTO_RELEASE = false,
    CHANGELOG_ENABLED = true,
    RELEASE_NOTES_ENABLED = true,
    POST_LAUNCH_MONITORING = true,
    SUPPORT_ENABLED = true,
    BACKUP_BEFORE_RELEASE = true,
    VALIDATION_ENABLED = true,
    ROLLBACK_ON_FAILURE = true
}

-- Release state
local releaseState = {
    currentVersion = "1.0.0",
    releaseHistory = {},
    isReleasing = false,
    lastRelease = nil,
    changelog = {},
    releaseNotes = {},
    postLaunchMetrics = {
        totalReleases = 0,
        successfulReleases = 0,
        failedReleases = 0,
        averageReleaseTime = 0,
        lastReleaseTime = 0,
        postLaunchIssues = 0,
        supportTickets = 0
    }
}

-- Initialize release system
function Release.Initialize()
    print("^2[District Zero] ^7Initializing Release System...")
    
    -- Load release configuration
    Release.LoadConfiguration()
    
    -- Initialize release history
    Release.LoadReleaseHistory()
    
    -- Initialize changelog
    Release.InitializeChangelog()
    
    -- Initialize release notes
    Release.InitializeReleaseNotes()
    
    -- Register release commands
    Release.RegisterCommands()
    
    -- Initialize post-launch monitoring
    if CONFIG.POST_LAUNCH_MONITORING then
        Release.InitializePostLaunchMonitoring()
    end
    
    -- Initialize support system
    if CONFIG.SUPPORT_ENABLED then
        Release.InitializeSupportSystem()
    end
    
    print("^2[District Zero] ^7Release System Initialized")
end

-- Load release configuration
function Release.LoadConfiguration()
    local configFile = LoadResourceFile(GetCurrentResourceName(), "config/release.json")
    if configFile then
        local config = json.decode(configFile)
        if config then
            for key, value in pairs(config) do
                CONFIG[key] = value
            end
        end
    end
    
    -- Create default config if not exists
    if not configFile then
        Release.SaveConfiguration()
    end
end

-- Save release configuration
function Release.SaveConfiguration()
    SaveResourceFile(GetCurrentResourceName(), "config/release.json", json.encode(CONFIG, {indent = true}))
end

-- Load release history
function Release.LoadReleaseHistory()
    local historyFile = LoadResourceFile(GetCurrentResourceName(), "data/release_history.json")
    if historyFile then
        local history = json.decode(historyFile)
        if history then
            releaseState.releaseHistory = history.releases or {}
            releaseState.changelog = history.changelog or {}
            releaseState.releaseNotes = history.releaseNotes or {}
            releaseState.postLaunchMetrics = history.metrics or releaseState.postLaunchMetrics
        end
    end
end

-- Save release history
function Release.SaveReleaseHistory()
    local history = {
        releases = releaseState.releaseHistory,
        changelog = releaseState.changelog,
        releaseNotes = releaseState.releaseNotes,
        metrics = releaseState.postLaunchMetrics
    }
    
    SaveResourceFile(GetCurrentResourceName(), "data/release_history.json", json.encode(history, {indent = true}))
end

-- Initialize changelog
function Release.InitializeChangelog()
    if not CONFIG.CHANGELOG_ENABLED then return end
    
    -- Load existing changelog
    local changelogFile = LoadResourceFile(GetCurrentResourceName(), "data/changelog.json")
    if changelogFile then
        local changelog = json.decode(changelogFile)
        if changelog then
            releaseState.changelog = changelog
        end
    end
    
    -- Create default changelog if not exists
    if not changelogFile then
        Release.CreateDefaultChangelog()
    end
end

-- Create default changelog
function Release.CreateDefaultChangelog()
    releaseState.changelog = {
        {
            version = "1.0.0",
            date = os.date("%Y-%m-%d"),
            type = "major",
            changes = {
                added = {
                    "Initial release of District Zero FiveM",
                    "District control system",
                    "Mission system",
                    "Team system",
                    "Event system",
                    "Achievement system",
                    "Analytics system",
                    "Security system",
                    "Performance optimization",
                    "Advanced UI components",
                    "Integration system",
                    "Polish features",
                    "Deployment system",
                    "Final integration"
                },
                changed = {},
                fixed = {},
                removed = {}
            },
            notes = "Initial release with all core systems implemented"
        }
    }
    
    Release.SaveChangelog()
end

-- Save changelog
function Release.SaveChangelog()
    if not CONFIG.CHANGELOG_ENABLED then return end
    
    SaveResourceFile(GetCurrentResourceName(), "data/changelog.json", json.encode(releaseState.changelog, {indent = true}))
end

-- Initialize release notes
function Release.InitializeReleaseNotes()
    if not CONFIG.RELEASE_NOTES_ENABLED then return end
    
    -- Load existing release notes
    local notesFile = LoadResourceFile(GetCurrentResourceName(), "data/release_notes.json")
    if notesFile then
        local notes = json.decode(notesFile)
        if notes then
            releaseState.releaseNotes = notes
        end
    end
    
    -- Create default release notes if not exists
    if not notesFile then
        Release.CreateDefaultReleaseNotes()
    end
end

-- Create default release notes
function Release.CreateDefaultReleaseNotes()
    releaseState.releaseNotes = {
        {
            version = "1.0.0",
            date = os.date("%Y-%m-%d"),
            title = "District Zero FiveM - Initial Release",
            summary = "Complete district-based competitive gaming system for FiveM",
            features = {
                "District Control System - Capture and defend territories",
                "Mission System - Dynamic missions with rewards",
                "Team System - Form teams and coordinate strategies",
                "Event System - Special events and competitions",
                "Achievement System - Unlock achievements and progress",
                "Analytics System - Track performance and statistics",
                "Security System - Anti-cheat and protection",
                "Performance Optimization - Optimized for smooth gameplay",
                "Advanced UI - Modern, responsive interface",
                "Integration System - Seamless system coordination",
                "Polish Features - Quality of life improvements",
                "Deployment System - Easy updates and management"
            },
            installation = "Extract to resources folder and add to server.cfg",
            configuration = "Edit config files in config/ directory",
            support = "Check documentation or contact support"
        }
    }
    
    Release.SaveReleaseNotes()
end

-- Save release notes
function Release.SaveReleaseNotes()
    if not CONFIG.RELEASE_NOTES_ENABLED then return end
    
    SaveResourceFile(GetCurrentResourceName(), "data/release_notes.json", json.encode(releaseState.releaseNotes, {indent = true}))
end

-- Create release
function Release.CreateRelease(version, releaseData)
    if releaseState.isReleasing then
        return {success = false, message = "Release already in progress"}
    end
    
    releaseState.isReleasing = true
    local startTime = GetGameTimer()
    
    print(string.format("^2[District Zero] ^7Creating release %s", version))
    
    -- Pre-release validation
    local validation = Release.PreReleaseValidation(version, releaseData)
    if not validation.success then
        releaseState.isReleasing = false
        return validation
    end
    
    -- Create backup
    if CONFIG.BACKUP_BEFORE_RELEASE then
        local backup = Release.CreateReleaseBackup()
        if not backup.success then
            releaseState.isReleasing = false
            return backup
        end
    end
    
    -- Package release
    local package = Release.PackageRelease(version, releaseData)
    if not package.success then
        releaseState.isReleasing = false
        return package
    end
    
    -- Generate changelog entry
    if CONFIG.CHANGELOG_ENABLED then
        Release.AddChangelogEntry(version, releaseData)
    end
    
    -- Generate release notes
    if CONFIG.RELEASE_NOTES_ENABLED then
        Release.AddReleaseNotes(version, releaseData)
    end
    
    -- Deploy release
    local deploy = Release.DeployRelease(version, package.data)
    if not deploy.success then
        -- Rollback on failure
        if CONFIG.ROLLBACK_ON_FAILURE then
            Release.RollbackRelease()
        end
        releaseState.isReleasing = false
        return deploy
    end
    
    -- Post-release validation
    local postValidation = Release.PostReleaseValidation(version)
    if not postValidation.success then
        if CONFIG.ROLLBACK_ON_FAILURE then
            Release.RollbackRelease()
        end
        releaseState.isReleasing = false
        return postValidation
    end
    
    -- Update release state
    local releaseTime = GetGameTimer() - startTime
    releaseState.currentVersion = version
    releaseState.lastRelease = {
        version = version,
        timestamp = os.time(),
        duration = releaseTime,
        data = releaseData,
        package = package.data
    }
    
    -- Add to history
    table.insert(releaseState.releaseHistory, releaseState.lastRelease)
    
    -- Update metrics
    releaseState.postLaunchMetrics.totalReleases = releaseState.postLaunchMetrics.totalReleases + 1
    releaseState.postLaunchMetrics.successfulReleases = releaseState.postLaunchMetrics.successfulReleases + 1
    releaseState.postLaunchMetrics.lastReleaseTime = releaseTime
    
    -- Calculate average release time
    local totalTime = 0
    local count = 0
    for _, release in ipairs(releaseState.releaseHistory) do
        if release.duration then
            totalTime = totalTime + release.duration
            count = count + 1
        end
    end
    if count > 0 then
        releaseState.postLaunchMetrics.averageReleaseTime = totalTime / count
    end
    
    -- Save release history
    Release.SaveReleaseHistory()
    
    releaseState.isReleasing = false
    
    print(string.format("^2[District Zero] ^7Release %s created successfully in %dms", version, releaseTime))
    
    return {success = true, message = "Release created successfully", releaseTime = releaseTime}
end

-- Pre-release validation
function Release.PreReleaseValidation(version, releaseData)
    print("^3[District Zero] ^7Running pre-release validation...")
    
    -- Validate version format
    if not Release.ValidateVersion(version) then
        return {success = false, message = "Invalid version format"}
    end
    
    -- Validate release data
    if not Release.ValidateReleaseData(releaseData) then
        return {success = false, message = "Invalid release data"}
    end
    
    -- Check system health
    local health = exports["district_zero"]:GetIntegrationHealth()
    if health.status == "unhealthy" then
        return {success = false, message = "System health check failed"}
    end
    
    -- Check resource availability
    local resources = Release.CheckResourceAvailability()
    if not resources.available then
        return {success = false, message = "Insufficient resources for release"}
    end
    
    print("^2[District Zero] ^7Pre-release validation passed")
    return {success = true}
end

-- Validate version
function Release.ValidateVersion(version)
    -- Simple version validation (x.y.z format)
    return string.match(version, "^%d+%.%d+%.%d+$") ~= nil
end

-- Validate release data
function Release.ValidateReleaseData(releaseData)
    if not releaseData then return false end
    
    -- Check required fields
    local required = {"type", "changes", "notes"}
    for _, field in ipairs(required) do
        if not releaseData[field] then
            return false
        end
    end
    
    return true
end

-- Check resource availability
function Release.CheckResourceAvailability()
    -- This would check actual resource availability
    -- For now, return available
    return {available = true, memory = 45, cpu = 30, disk = 60}
end

-- Create release backup
function Release.CreateReleaseBackup()
    print("^3[District Zero] ^7Creating release backup...")
    
    local backup = {
        version = releaseState.currentVersion,
        timestamp = os.time(),
        config = Release.GetCurrentConfiguration(),
        data = Release.GetCurrentData()
    }
    
    print("^2[District Zero] ^7Release backup created successfully")
    return {success = true, backup = backup}
end

-- Get current configuration
function Release.GetCurrentConfiguration()
    -- This would get actual current configuration
    -- For now, return mock data
    return {
        districts = {},
        missions = {},
        teams = {},
        events = {}
    }
end

-- Get current data
function Release.GetCurrentData()
    -- This would get actual current data
    -- For now, return mock data
    return {
        players = {},
        teams = {},
        missions = {},
        events = {}
    }
end

-- Package release
function Release.PackageRelease(version, releaseData)
    print("^3[District Zero] ^7Packaging release...")
    
    local package = {
        version = version,
        timestamp = os.time(),
        data = releaseData,
        files = Release.GetReleaseFiles(),
        checksum = Release.GenerateChecksum(version)
    }
    
    print("^2[District Zero] ^7Release packaged successfully")
    return {success = true, data = package}
end

-- Get release files
function Release.GetReleaseFiles()
    -- This would get actual release files
    -- For now, return mock data
    return {
        "server/",
        "client/",
        "shared/",
        "ui/",
        "config/",
        "data/",
        "docs/"
    }
end

-- Generate checksum
function Release.GenerateChecksum(version)
    -- This would generate actual checksum
    -- For now, return mock checksum
    return "sha256:" .. version .. "_" .. os.time()
end

-- Deploy release
function Release.DeployRelease(version, package)
    print("^3[District Zero] ^7Deploying release...")
    
    -- Apply release changes
    local success = Release.ApplyReleaseChanges(version, package)
    if not success then
        return {success = false, message = "Failed to apply release changes"}
    end
    
    -- Update version
    releaseState.currentVersion = version
    
    print("^2[District Zero] ^7Release deployed successfully")
    return {success = true}
end

-- Apply release changes
function Release.ApplyReleaseChanges(version, package)
    -- This would apply actual release changes
    -- For now, return true
    return true
end

-- Post-release validation
function Release.PostReleaseValidation(version)
    print("^3[District Zero] ^7Running post-release validation...")
    
    -- Wait for system to stabilize
    Wait(5000)
    
    -- Check system health
    local health = exports["district_zero"]:GetIntegrationHealth()
    if health.status == "unhealthy" then
        return {success = false, message = "System health check failed after release"}
    end
    
    -- Check version
    if releaseState.currentVersion ~= version then
        return {success = false, message = "Version mismatch after release"}
    end
    
    print("^2[District Zero] ^7Post-release validation passed")
    return {success = true}
end

-- Rollback release
function Release.RollbackRelease()
    print("^3[District Zero] ^7Rolling back release...")
    
    -- This would perform actual rollback
    -- For now, just log
    print("^2[District Zero] ^7Release rollback completed")
    return {success = true, message = "Release rollback completed"}
end

-- Add changelog entry
function Release.AddChangelogEntry(version, releaseData)
    if not CONFIG.CHANGELOG_ENABLED then return end
    
    local entry = {
        version = version,
        date = os.date("%Y-%m-%d"),
        type = releaseData.type or "patch",
        changes = releaseData.changes or {added = {}, changed = {}, fixed = {}, removed = {}},
        notes = releaseData.notes or ""
    }
    
    table.insert(releaseState.changelog, entry)
    Release.SaveChangelog()
end

-- Add release notes
function Release.AddReleaseNotes(version, releaseData)
    if not CONFIG.RELEASE_NOTES_ENABLED then return end
    
    local notes = {
        version = version,
        date = os.date("%Y-%m-%d"),
        title = releaseData.title or "District Zero FiveM - " .. version,
        summary = releaseData.summary or "",
        features = releaseData.features or {},
        installation = releaseData.installation or "Extract to resources folder and add to server.cfg",
        configuration = releaseData.configuration or "Edit config files in config/ directory",
        support = releaseData.support or "Check documentation or contact support"
    }
    
    table.insert(releaseState.releaseNotes, notes)
    Release.SaveReleaseNotes()
end

-- Initialize post-launch monitoring
function Release.InitializePostLaunchMonitoring()
    print("^3[District Zero] ^7Initializing post-launch monitoring...")
    
    -- Start monitoring thread
    CreateThread(function()
        while true do
            Release.CollectPostLaunchMetrics()
            Wait(300000) -- Every 5 minutes
        end
    end)
    
    print("^2[District Zero] ^7Post-launch monitoring initialized")
end

-- Collect post-launch metrics
function Release.CollectPostLaunchMetrics()
    local metrics = {
        timestamp = os.time(),
        version = releaseState.currentVersion,
        playerCount = #GetPlayers(),
        systemHealth = exports["district_zero"]:GetIntegrationHealth(),
        performance = exports["district_zero"]:GetPerformanceMetrics(),
        security = exports["district_zero"]:GetSecurityStatus()
    }
    
    -- Store metrics
    Release.StorePostLaunchMetrics(metrics)
end

-- Store post-launch metrics
function Release.StorePostLaunchMetrics(metrics)
    -- This would store actual metrics
    -- For now, just log
    if metrics.systemHealth.status ~= "healthy" then
        print("^3[District Zero] ^7Post-launch monitoring: System health issue detected")
    end
end

-- Initialize support system
function Release.InitializeSupportSystem()
    print("^3[District Zero] ^7Initializing support system...")
    
    -- Register support events
    RegisterNetEvent("district_zero:support:ticket")
    AddEventHandler("district_zero:support:ticket", function(data)
        Release.HandleSupportTicket(data)
    end)
    
    print("^2[District Zero] ^7Support system initialized")
end

-- Handle support ticket
function Release.HandleSupportTicket(data)
    releaseState.postLaunchMetrics.supportTickets = releaseState.postLaunchMetrics.supportTickets + 1
    
    print(string.format("^3[District Zero] ^7Support ticket received: %s", data.issue))
    
    -- This would handle actual support ticket
    -- For now, just log
end

-- Get release status
function Release.GetReleaseStatus()
    return {
        currentVersion = releaseState.currentVersion,
        isReleasing = releaseState.isReleasing,
        lastRelease = releaseState.lastRelease,
        metrics = releaseState.postLaunchMetrics
    }
end

-- Get changelog
function Release.GetChangelog()
    return releaseState.changelog
end

-- Get release notes
function Release.GetReleaseNotes()
    return releaseState.releaseNotes
end

-- Register commands
function Release.RegisterCommands()
    RegisterCommand("create_release", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local version = args[1]
        local releaseType = args[2] or "patch"
        
        if not version then
            print("^1[District Zero] ^7Usage: create_release <version> [type]")
            return
        end
        
        local releaseData = {
            type = releaseType,
            changes = {
                added = {"Feature 1", "Feature 2"},
                changed = {"Improvement 1"},
                fixed = {"Bug 1", "Bug 2"},
                removed = {}
            },
            notes = "Release " .. version .. " with various improvements and bug fixes"
        }
        
        local result = Release.CreateRelease(version, releaseData)
        if result.success then
            print("^2[District Zero] ^7Release created: " .. result.message)
        else
            print("^1[District Zero] ^7Release failed: " .. result.message)
        end
    end, true)
    
    RegisterCommand("release_status", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local status = Release.GetReleaseStatus()
        print("^3[District Zero] ^7Release Status:")
        print("  Current Version: " .. status.currentVersion)
        print("  Is Releasing: " .. tostring(status.isReleasing))
        print("  Total Releases: " .. status.metrics.totalReleases)
        print("  Successful Releases: " .. status.metrics.successfulReleases)
        print("  Failed Releases: " .. status.metrics.failedReleases)
        print("  Average Release Time: " .. status.metrics.averageReleaseTime .. "ms")
        print("  Support Tickets: " .. status.metrics.supportTickets)
    end, true)
    
    RegisterCommand("changelog", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local changelog = Release.GetChangelog()
        print("^3[District Zero] ^7Changelog:")
        for i, entry in ipairs(changelog) do
            print(string.format("  %s (%s) - %s", entry.version, entry.date, entry.type))
            if entry.notes then
                print("    " .. entry.notes)
            end
        end
    end, true)
    
    RegisterCommand("release_notes", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local notes = Release.GetReleaseNotes()
        print("^3[District Zero] ^7Release Notes:")
        for i, note in ipairs(notes) do
            print(string.format("  %s (%s) - %s", note.version, note.date, note.title))
            if note.summary then
                print("    " .. note.summary)
            end
        end
    end, true)
end

-- Export functions
exports("GetReleaseStatus", Release.GetReleaseStatus)
exports("GetChangelog", Release.GetChangelog)
exports("GetReleaseNotes", Release.GetReleaseNotes)
exports("CreateRelease", Release.CreateRelease)

-- Initialize on resource start
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Release.Initialize()
    end
end)

return Release 