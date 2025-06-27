-- District Zero Advanced Analytics System
-- Version: 1.0.0

local AnalyticsSystem = {
    -- Analytics Categories
    categories = {
        PLAYER_BEHAVIOR = 'player_behavior',
        TEAM_PERFORMANCE = 'team_performance',
        DISTRICT_CONTROL = 'district_control',
        MISSION_STATISTICS = 'mission_statistics',
        SYSTEM_METRICS = 'system_metrics',
        ECONOMIC_ANALYTICS = 'economic_analytics',
        SOCIAL_ANALYTICS = 'social_analytics',
        PERFORMANCE_ANALYTICS = 'performance_analytics'
    },
    
    -- Analytics Types
    types = {
        COUNTER = 'counter',
        TIMER = 'timer',
        AVERAGE = 'average',
        PERCENTAGE = 'percentage',
        TREND = 'trend',
        DISTRIBUTION = 'distribution',
        CORRELATION = 'correlation'
    },
    
    -- Analytics Data
    analyticsData = {},
    
    -- Player Behavior Analytics
    playerBehavior = {},
    
    -- Team Performance Analytics
    teamPerformance = {},
    
    -- District Control Analytics
    districtControl = {},
    
    -- Mission Statistics
    missionStatistics = {},
    
    -- System Metrics
    systemMetrics = {},
    
    -- Economic Analytics
    economicAnalytics = {},
    
    -- Social Analytics
    socialAnalytics = {},
    
    -- Performance Analytics
    performanceAnalytics = {},
    
    -- Analytics Templates
    analyticsTemplates = {
        -- Player Behavior Analytics
        player_session_time = {
            id = 'player_session_time',
            name = 'Session Duration',
            description = 'Average player session duration',
            category = 'player_behavior',
            type = 'average',
            unit = 'minutes',
            updateInterval = 300000, -- 5 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local total = 0
                local count = 0
                for _, session in pairs(data) do
                    total = total + session.duration
                    count = count + 1
                end
                return count > 0 and total / count / 60000 or 0
            end
        },
        
        player_activity_patterns = {
            id = 'player_activity_patterns',
            name = 'Activity Patterns',
            description = 'Player activity throughout the day',
            category = 'player_behavior',
            type = 'distribution',
            unit = 'players',
            updateInterval = 3600000, -- 1 hour
            retention = 2592000000, -- 30 days
            calculation = function(data)
                local hourlyDistribution = {}
                for hour = 0, 23 do
                    hourlyDistribution[hour] = 0
                end
                
                for _, activity in pairs(data) do
                    local hour = os.date('%H', activity.timestamp / 1000)
                    hourlyDistribution[tonumber(hour)] = (hourlyDistribution[tonumber(hour)] or 0) + 1
                end
                
                return hourlyDistribution
            end
        },
        
        player_movement_analysis = {
            id = 'player_movement_analysis',
            name = 'Movement Analysis',
            description = 'Player movement patterns and distances',
            category = 'player_behavior',
            type = 'trend',
            unit = 'meters',
            updateInterval = 60000, -- 1 minute
            retention = 86400000, -- 1 day
            calculation = function(data)
                local totalDistance = 0
                local totalTime = 0
                local speeds = {}
                
                for _, movement in pairs(data) do
                    totalDistance = totalDistance + movement.distance
                    totalTime = totalTime + movement.duration
                    table.insert(speeds, movement.distance / (movement.duration / 1000))
                end
                
                return {
                    totalDistance = totalDistance,
                    averageSpeed = totalTime > 0 and totalDistance / (totalTime / 1000) or 0,
                    speedDistribution = speeds
                }
            end
        },
        
        player_combat_behavior = {
            id = 'player_combat_behavior',
            name = 'Combat Behavior',
            description = 'Player combat patterns and statistics',
            category = 'player_behavior',
            type = 'correlation',
            unit = 'events',
            updateInterval = 300000, -- 5 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local kills = 0
                local deaths = 0
                local assists = 0
                local combatTime = 0
                
                for _, combat in pairs(data) do
                    kills = kills + (combat.kills or 0)
                    deaths = deaths + (combat.deaths or 0)
                    assists = assists + (combat.assists or 0)
                    combatTime = combatTime + (combat.duration or 0)
                end
                
                return {
                    kills = kills,
                    deaths = deaths,
                    assists = assists,
                    kdr = deaths > 0 and kills / deaths or kills,
                    combatTime = combatTime,
                    averageCombatTime = #data > 0 and combatTime / #data or 0
                }
            end
        },
        
        -- Team Performance Analytics
        team_capture_efficiency = {
            id = 'team_capture_efficiency',
            name = 'Capture Efficiency',
            description = 'Team district capture success rate',
            category = 'team_performance',
            type = 'percentage',
            unit = '%',
            updateInterval = 600000, -- 10 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local successful = 0
                local total = 0
                
                for _, capture in pairs(data) do
                    total = total + 1
                    if capture.successful then
                        successful = successful + 1
                    end
                end
                
                return total > 0 and (successful / total) * 100 or 0
            end
        },
        
        team_mission_completion = {
            id = 'team_mission_completion',
            name = 'Mission Completion Rate',
            description = 'Team mission completion statistics',
            category = 'team_performance',
            type = 'trend',
            unit = 'missions',
            updateInterval = 300000, -- 5 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local completed = 0
                local failed = 0
                local totalTime = 0
                local missionTypes = {}
                
                for _, mission in pairs(data) do
                    if mission.completed then
                        completed = completed + 1
                        totalTime = totalTime + mission.duration
                    else
                        failed = failed + 1
                    end
                    
                    missionTypes[mission.type] = (missionTypes[mission.type] or 0) + 1
                end
                
                return {
                    completed = completed,
                    failed = failed,
                    successRate = (completed + failed) > 0 and (completed / (completed + failed)) * 100 or 0,
                    averageCompletionTime = completed > 0 and totalTime / completed or 0,
                    missionTypeDistribution = missionTypes
                }
            end
        },
        
        team_war_performance = {
            id = 'team_war_performance',
            name = 'War Performance',
            description = 'Team war statistics and performance',
            category = 'team_performance',
            type = 'correlation',
            unit = 'wars',
            updateInterval = 1800000, -- 30 minutes
            retention = 2592000000, -- 30 days
            calculation = function(data)
                local wins = 0
                local losses = 0
                local totalScore = 0
                local averageDuration = 0
                
                for _, war in pairs(data) do
                    if war.winner == war.teamId then
                        wins = wins + 1
                    else
                        losses = losses + 1
                    end
                    
                    totalScore = totalScore + war.score
                    averageDuration = averageDuration + war.duration
                end
                
                return {
                    wins = wins,
                    losses = losses,
                    winRate = (wins + losses) > 0 and (wins / (wins + losses)) * 100 or 0,
                    averageScore = #data > 0 and totalScore / #data or 0,
                    averageDuration = #data > 0 and averageDuration / #data or 0
                }
            end
        },
        
        -- District Control Analytics
        district_control_duration = {
            id = 'district_control_duration',
            name = 'Control Duration',
            description = 'Average district control duration by team',
            category = 'district_control',
            type = 'average',
            unit = 'minutes',
            updateInterval = 600000, -- 10 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local totalDuration = 0
                local controlCount = 0
                local teamControl = {}
                
                for _, control in pairs(data) do
                    totalDuration = totalDuration + control.duration
                    controlCount = controlCount + 1
                    
                    teamControl[control.teamId] = (teamControl[control.teamId] or 0) + control.duration
                end
                
                return {
                    averageDuration = controlCount > 0 and totalDuration / controlCount / 60000 or 0,
                    totalControls = controlCount,
                    teamControlDistribution = teamControl
                }
            end
        },
        
        district_capture_frequency = {
            id = 'district_capture_frequency',
            name = 'Capture Frequency',
            description = 'District capture frequency and patterns',
            category = 'district_control',
            type = 'trend',
            unit = 'captures/hour',
            updateInterval = 3600000, -- 1 hour
            retention = 604800000, -- 7 days
            calculation = function(data)
                local hourlyCaptures = {}
                local districtCaptures = {}
                
                for hour = 0, 23 do
                    hourlyCaptures[hour] = 0
                end
                
                for _, capture in pairs(data) do
                    local hour = os.date('%H', capture.timestamp / 1000)
                    hourlyCaptures[tonumber(hour)] = (hourlyCaptures[tonumber(hour)] or 0) + 1
                    
                    districtCaptures[capture.districtId] = (districtCaptures[capture.districtId] or 0) + 1
                end
                
                return {
                    hourlyDistribution = hourlyCaptures,
                    districtDistribution = districtCaptures,
                    totalCaptures = #data
                }
            end
        },
        
        -- Mission Statistics
        mission_completion_rate = {
            id = 'mission_completion_rate',
            name = 'Mission Completion Rate',
            description = 'Overall mission completion statistics',
            category = 'mission_statistics',
            type = 'percentage',
            unit = '%',
            updateInterval = 300000, -- 5 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local completed = 0
                local total = 0
                local missionTypes = {}
                
                for _, mission in pairs(data) do
                    total = total + 1
                    if mission.completed then
                        completed = completed + 1
                    end
                    
                    missionTypes[mission.type] = (missionTypes[mission.type] or 0) + 1
                end
                
                return {
                    completionRate = total > 0 and (completed / total) * 100 or 0,
                    totalMissions = total,
                    completedMissions = completed,
                    missionTypeDistribution = missionTypes
                }
            end
        },
        
        mission_difficulty_analysis = {
            id = 'mission_difficulty_analysis',
            name = 'Difficulty Analysis',
            description = 'Mission difficulty and success correlation',
            category = 'mission_statistics',
            type = 'correlation',
            unit = 'missions',
            updateInterval = 600000, -- 10 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local difficultyStats = {}
                
                for _, mission in pairs(data) do
                    local difficulty = mission.difficulty or 'normal'
                    if not difficultyStats[difficulty] then
                        difficultyStats[difficulty] = { total = 0, completed = 0 }
                    end
                    
                    difficultyStats[difficulty].total = difficultyStats[difficulty].total + 1
                    if mission.completed then
                        difficultyStats[difficulty].completed = difficultyStats[difficulty].completed + 1
                    end
                end
                
                -- Calculate success rates
                for difficulty, stats in pairs(difficultyStats) do
                    stats.successRate = stats.total > 0 and (stats.completed / stats.total) * 100 or 0
                end
                
                return difficultyStats
            end
        },
        
        -- System Metrics
        server_performance = {
            id = 'server_performance',
            name = 'Server Performance',
            description = 'Server performance metrics and health',
            category = 'system_metrics',
            type = 'trend',
            unit = 'metrics',
            updateInterval = 60000, -- 1 minute
            retention = 86400000, -- 1 day
            calculation = function(data)
                local cpuUsage = 0
                local memoryUsage = 0
                local playerCount = 0
                local eventCount = 0
                
                for _, metric in pairs(data) do
                    cpuUsage = cpuUsage + (metric.cpu or 0)
                    memoryUsage = memoryUsage + (metric.memory or 0)
                    playerCount = playerCount + (metric.players or 0)
                    eventCount = eventCount + (metric.events or 0)
                end
                
                return {
                    averageCpu = #data > 0 and cpuUsage / #data or 0,
                    averageMemory = #data > 0 and memoryUsage / #data or 0,
                    averagePlayers = #data > 0 and playerCount / #data or 0,
                    totalEvents = eventCount
                }
            end
        },
        
        -- Economic Analytics
        economic_flow = {
            id = 'economic_flow',
            name = 'Economic Flow',
            description = 'In-game economy flow and distribution',
            category = 'economic_analytics',
            type = 'trend',
            unit = 'currency',
            updateInterval = 300000, -- 5 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local totalInflow = 0
                local totalOutflow = 0
                local sourceDistribution = {}
                local sinkDistribution = {}
                
                for _, transaction in pairs(data) do
                    if transaction.type == 'inflow' then
                        totalInflow = totalInflow + transaction.amount
                        sourceDistribution[transaction.source] = (sourceDistribution[transaction.source] or 0) + transaction.amount
                    else
                        totalOutflow = totalOutflow + transaction.amount
                        sinkDistribution[transaction.sink] = (sinkDistribution[transaction.sink] or 0) + transaction.amount
                    end
                end
                
                return {
                    totalInflow = totalInflow,
                    totalOutflow = totalOutflow,
                    netFlow = totalInflow - totalOutflow,
                    sourceDistribution = sourceDistribution,
                    sinkDistribution = sinkDistribution
                }
            end
        },
        
        -- Social Analytics
        social_interactions = {
            id = 'social_interactions',
            name = 'Social Interactions',
            description = 'Player social interaction patterns',
            category = 'social_analytics',
            type = 'distribution',
            unit = 'interactions',
            updateInterval = 600000, -- 10 minutes
            retention = 604800000, -- 7 days
            calculation = function(data)
                local interactionTypes = {}
                local playerInteractions = {}
                local teamInteractions = {}
                
                for _, interaction in pairs(data) do
                    interactionTypes[interaction.type] = (interactionTypes[interaction.type] or 0) + 1
                    playerInteractions[interaction.playerId] = (playerInteractions[interaction.playerId] or 0) + 1
                    teamInteractions[interaction.teamId] = (teamInteractions[interaction.teamId] or 0) + 1
                end
                
                return {
                    totalInteractions = #data,
                    interactionTypeDistribution = interactionTypes,
                    playerInteractionDistribution = playerInteractions,
                    teamInteractionDistribution = teamInteractions
                }
            end
        },
        
        -- Performance Analytics
        performance_metrics = {
            id = 'performance_metrics',
            name = 'Performance Metrics',
            description = 'System performance and optimization metrics',
            category = 'performance_analytics',
            type = 'trend',
            unit = 'metrics',
            updateInterval = 30000, -- 30 seconds
            retention = 86400000, -- 1 day
            calculation = function(data)
                local fps = 0
                local latency = 0
                local memoryUsage = 0
                local cpuUsage = 0
                
                for _, metric in pairs(data) do
                    fps = fps + (metric.fps or 0)
                    latency = latency + (metric.latency or 0)
                    memoryUsage = memoryUsage + (metric.memory or 0)
                    cpuUsage = cpuUsage + (metric.cpu or 0)
                end
                
                return {
                    averageFps = #data > 0 and fps / #data or 0,
                    averageLatency = #data > 0 and latency / #data or 0,
                    averageMemory = #data > 0 and memoryUsage / #data or 0,
                    averageCpu = #data > 0 and cpuUsage / #data or 0
                }
            end
        }
    },
    
    -- Dashboard Templates
    dashboardTemplates = {
        overview = {
            id = 'overview',
            name = 'Overview Dashboard',
            description = 'General system overview and key metrics',
            metrics = {
                'player_session_time',
                'team_capture_efficiency',
                'district_control_duration',
                'mission_completion_rate',
                'server_performance',
                'economic_flow'
            },
            layout = 'grid',
            refreshInterval = 30000 -- 30 seconds
        },
        
        player_analytics = {
            id = 'player_analytics',
            name = 'Player Analytics Dashboard',
            description = 'Detailed player behavior and performance analytics',
            metrics = {
                'player_activity_patterns',
                'player_movement_analysis',
                'player_combat_behavior',
                'social_interactions'
            },
            layout = 'charts',
            refreshInterval = 60000 -- 1 minute
        },
        
        team_analytics = {
            id = 'team_analytics',
            name = 'Team Analytics Dashboard',
            description = 'Team performance and competitive analytics',
            metrics = {
                'team_capture_efficiency',
                'team_mission_completion',
                'team_war_performance'
            },
            layout = 'comparison',
            refreshInterval = 300000 -- 5 minutes
        },
        
        system_analytics = {
            id = 'system_analytics',
            name = 'System Analytics Dashboard',
            description = 'System performance and health monitoring',
            metrics = {
                'server_performance',
                'performance_metrics',
                'district_capture_frequency'
            },
            layout = 'monitoring',
            refreshInterval = 30000 -- 30 seconds
        }
    }
}

-- Analytics Data Management
local function InitializeAnalytics()
    for category, _ in pairs(AnalyticsSystem.categories) do
        AnalyticsSystem.analyticsData[category] = {}
    end
end

local function AddAnalyticsData(category, metricId, data)
    if not AnalyticsSystem.analyticsData[category] then
        AnalyticsSystem.analyticsData[category] = {}
    end
    
    if not AnalyticsSystem.analyticsData[category][metricId] then
        AnalyticsSystem.analyticsData[category][metricId] = {}
    end
    
    table.insert(AnalyticsSystem.analyticsData[category][metricId], {
        data = data,
        timestamp = GetGameTimer()
    })
    
    -- Cleanup old data based on retention
    local template = AnalyticsSystem.analyticsTemplates[metricId]
    if template and template.retention then
        local cutoffTime = GetGameTimer() - template.retention
        local newData = {}
        
        for _, entry in ipairs(AnalyticsSystem.analyticsData[category][metricId]) do
            if entry.timestamp > cutoffTime then
                table.insert(newData, entry)
            end
        end
        
        AnalyticsSystem.analyticsData[category][metricId] = newData
    end
end

local function CalculateAnalytics(metricId)
    local template = AnalyticsSystem.analyticsTemplates[metricId]
    if not template then
        return nil
    end
    
    local category = template.category
    local data = AnalyticsSystem.analyticsData[category][metricId]
    
    if not data or #data == 0 then
        return nil
    end
    
    -- Extract data for calculation
    local calculationData = {}
    for _, entry in ipairs(data) do
        table.insert(calculationData, entry.data)
    end
    
    -- Calculate result
    local result = template.calculation(calculationData)
    
    return {
        metricId = metricId,
        name = template.name,
        description = template.description,
        category = template.category,
        type = template.type,
        unit = template.unit,
        value = result,
        timestamp = GetGameTimer(),
        dataPoints = #data
    }
end

local function GetDashboardData(dashboardId)
    local template = AnalyticsSystem.dashboardTemplates[dashboardId]
    if not template then
        return nil
    end
    
    local dashboardData = {
        id = dashboardId,
        name = template.name,
        description = template.description,
        layout = template.layout,
        refreshInterval = template.refreshInterval,
        metrics = {}
    }
    
    for _, metricId in ipairs(template.metrics) do
        local metricData = CalculateAnalytics(metricId)
        if metricData then
            table.insert(dashboardData.metrics, metricData)
        end
    end
    
    return dashboardData
end

-- Real-time Analytics Tracking
local function TrackPlayerBehavior(playerId, behaviorType, data)
    AddAnalyticsData('player_behavior', 'player_' .. behaviorType, {
        playerId = playerId,
        type = behaviorType,
        data = data
    })
end

local function TrackTeamPerformance(teamId, performanceType, data)
    AddAnalyticsData('team_performance', 'team_' .. performanceType, {
        teamId = teamId,
        type = performanceType,
        data = data
    })
end

local function TrackDistrictControl(districtId, controlType, data)
    AddAnalyticsData('district_control', 'district_' .. controlType, {
        districtId = districtId,
        type = controlType,
        data = data
    })
end

local function TrackMissionStatistics(missionId, statType, data)
    AddAnalyticsData('mission_statistics', 'mission_' .. statType, {
        missionId = missionId,
        type = statType,
        data = data
    })
end

local function TrackSystemMetrics(metricType, data)
    AddAnalyticsData('system_metrics', 'system_' .. metricType, {
        type = metricType,
        data = data
    })
end

local function TrackEconomicAnalytics(transactionType, data)
    AddAnalyticsData('economic_analytics', 'economic_' .. transactionType, {
        type = transactionType,
        data = data
    })
end

local function TrackSocialAnalytics(interactionType, data)
    AddAnalyticsData('social_analytics', 'social_' .. interactionType, {
        type = interactionType,
        data = data
    })
end

local function TrackPerformanceAnalytics(performanceType, data)
    AddAnalyticsData('performance_analytics', 'performance_' .. performanceType, {
        type = performanceType,
        data = data
    })
end

-- Analytics System Methods
AnalyticsSystem.InitializeAnalytics = InitializeAnalytics
AnalyticsSystem.AddAnalyticsData = AddAnalyticsData
AnalyticsSystem.CalculateAnalytics = CalculateAnalytics
AnalyticsSystem.GetDashboardData = GetDashboardData
AnalyticsSystem.TrackPlayerBehavior = TrackPlayerBehavior
AnalyticsSystem.TrackTeamPerformance = TrackTeamPerformance
AnalyticsSystem.TrackDistrictControl = TrackDistrictControl
AnalyticsSystem.TrackMissionStatistics = TrackMissionStatistics
AnalyticsSystem.TrackSystemMetrics = TrackSystemMetrics
AnalyticsSystem.TrackEconomicAnalytics = TrackEconomicAnalytics
AnalyticsSystem.TrackSocialAnalytics = TrackSocialAnalytics
AnalyticsSystem.TrackPerformanceAnalytics = TrackPerformanceAnalytics

-- Initialize analytics system
InitializeAnalytics()

-- Exports
exports('InitializeAnalytics', InitializeAnalytics)
exports('AddAnalyticsData', AddAnalyticsData)
exports('CalculateAnalytics', CalculateAnalytics)
exports('GetDashboardData', GetDashboardData)
exports('TrackPlayerBehavior', TrackPlayerBehavior)
exports('TrackTeamPerformance', TrackTeamPerformance)
exports('TrackDistrictControl', TrackDistrictControl)
exports('TrackMissionStatistics', TrackMissionStatistics)
exports('TrackSystemMetrics', TrackSystemMetrics)
exports('TrackEconomicAnalytics', TrackEconomicAnalytics)
exports('TrackSocialAnalytics', TrackSocialAnalytics)
exports('TrackPerformanceAnalytics', TrackPerformanceAnalytics)

return AnalyticsSystem 