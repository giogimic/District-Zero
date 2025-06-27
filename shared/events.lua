-- District Zero Dynamic Events System
-- Version: 1.0.0

local DynamicEventsSystem = {
    -- Event Types
    eventTypes = {
        DISTRICT_INVASION = 'district_invasion',
        SUPPLY_DROP = 'supply_drop',
        BOSS_SPAWN = 'boss_spawn',
        WEATHER_EVENT = 'weather_event',
        SPECIAL_CHALLENGE = 'special_challenge',
        TEAM_WAR = 'team_war',
        RESOURCE_RUSH = 'resource_rush',
        ESCAPE_EVENT = 'escape_event',
        DEFENSE_EVENT = 'defense_event',
        INFILTRATION = 'infiltration'
    },
    
    -- Event States
    eventStates = {
        SCHEDULED = 'scheduled',
        ACTIVE = 'active',
        COMPLETED = 'completed',
        FAILED = 'failed',
        EXPIRED = 'expired'
    },
    
    -- Event Priorities
    priorities = {
        LOW = 1,
        NORMAL = 2,
        HIGH = 3,
        CRITICAL = 4,
        EMERGENCY = 5
    },
    
    -- Active Events
    activeEvents = {},
    
    -- Scheduled Events
    scheduledEvents = {},
    
    -- Event History
    eventHistory = {},
    
    -- Event Templates
    eventTemplates = {
        -- District Invasion Event
        district_invasion = {
            name = "District Invasion",
            description = "Hostile forces are invading the district! Defend or capture!",
            type = 'district_invasion',
            duration = 1800000, -- 30 minutes
            cooldown = 3600000, -- 1 hour
            priority = 4,
            maxPlayers = 12,
            requirements = {
                minPlayers = 2,
                minLevel = 1
            },
            objectives = {
                {
                    id = 'defend_district',
                    type = 'defense',
                    name = 'Defend District',
                    description = 'Prevent the invasion from capturing the district',
                    duration = 1800000, -- 30 minutes
                    required = true,
                    rewards = {
                        influence = 200,
                        experience = 400
                    }
                },
                {
                    id = 'eliminate_invaders',
                    type = 'elimination',
                    name = 'Eliminate Invaders',
                    description = 'Eliminate all invading forces',
                    targetCount = 20,
                    required = false,
                    rewards = {
                        influence = 100,
                        experience = 200
                    }
                }
            },
            rewards = {
                influence = 500,
                experience = 1000,
                money = 25000,
                specialReward = 'invasion_medal'
            },
            spawns = {
                enemies = {
                    { model = 's_m_y_swat_01', count = 10, coords = nil },
                    { model = 's_m_y_armymech_01', count = 5, coords = nil },
                    { model = 's_m_y_blackops_01', count = 3, coords = nil }
                },
                vehicles = {
                    { model = 'rhino', count = 2, coords = nil },
                    { model = 'lazer', count = 1, coords = nil }
                }
            }
        },
        
        -- Supply Drop Event
        supply_drop = {
            name = "Supply Drop",
            description = "Valuable supplies have been dropped in the district!",
            type = 'supply_drop',
            duration = 900000, -- 15 minutes
            cooldown = 1800000, -- 30 minutes
            priority = 2,
            maxPlayers = 8,
            requirements = {
                minPlayers = 1,
                minLevel = 1
            },
            objectives = {
                {
                    id = 'collect_supplies',
                    type = 'collection',
                    name = 'Collect Supplies',
                    description = 'Collect the dropped supplies before other teams',
                    targetCount = 5,
                    required = true,
                    rewards = {
                        influence = 75,
                        experience = 150
                    }
                },
                {
                    id = 'secure_drop_zone',
                    type = 'defense',
                    name = 'Secure Drop Zone',
                    description = 'Keep the drop zone secure while collecting',
                    duration = 300000, -- 5 minutes
                    required = false,
                    rewards = {
                        influence = 50,
                        experience = 100
                    }
                }
            },
            rewards = {
                influence = 200,
                experience = 400,
                money = 15000,
                specialReward = 'supply_cache'
            },
            spawns = {
                supplies = {
                    { model = 'prop_box_wood02a', count = 5, coords = nil },
                    { model = 'prop_box_wood04a', count = 3, coords = nil }
                }
            }
        },
        
        -- Boss Spawn Event
        boss_spawn = {
            name = "Boss Encounter",
            description = "A powerful enemy has appeared! Eliminate them!",
            type = 'boss_spawn',
            duration = 1200000, -- 20 minutes
            cooldown = 5400000, -- 1.5 hours
            priority = 5,
            maxPlayers = 10,
            requirements = {
                minPlayers = 3,
                minLevel = 3
            },
            objectives = {
                {
                    id = 'defeat_boss',
                    type = 'boss_fight',
                    name = 'Defeat Boss',
                    description = 'Eliminate the powerful boss enemy',
                    bossHealth = 2000,
                    required = true,
                    rewards = {
                        influence = 300,
                        experience = 600
                    }
                },
                {
                    id = 'survive_encounter',
                    type = 'survival',
                    name = 'Survive Encounter',
                    description = 'Survive the boss encounter',
                    duration = 1200000, -- 20 minutes
                    required = false,
                    rewards = {
                        influence = 100,
                        experience = 200
                    }
                }
            },
            rewards = {
                influence = 600,
                experience = 1200,
                money = 30000,
                specialReward = 'boss_weapon'
            },
            spawns = {
                boss = {
                    model = 's_m_y_blackops_03',
                    health = 2000,
                    armor = 100,
                    weapons = { 'WEAPON_RPG', 'WEAPON_MINIGUN' },
                    coords = nil
                },
                minions = {
                    { model = 's_m_y_swat_01', count = 8, coords = nil },
                    { model = 's_m_y_armymech_01', count = 4, coords = nil }
                }
            }
        },
        
        -- Weather Event
        weather_event = {
            name = "Weather Anomaly",
            description = "Extreme weather conditions affecting the district!",
            type = 'weather_event',
            duration = 600000, -- 10 minutes
            cooldown = 1800000, -- 30 minutes
            priority = 1,
            maxPlayers = 0, -- Affects all players
            requirements = {
                minPlayers = 0,
                minLevel = 1
            },
            objectives = {
                {
                    id = 'survive_weather',
                    type = 'survival',
                    name = 'Survive Weather',
                    description = 'Survive the extreme weather conditions',
                    duration = 600000, -- 10 minutes
                    required = true,
                    rewards = {
                        influence = 50,
                        experience = 100
                    }
                }
            },
            rewards = {
                influence = 100,
                experience = 200,
                money = 5000,
                specialReward = 'weather_resistant_gear'
            },
            weather = {
                type = 'THUNDER',
                intensity = 0.8,
                wind = 0.6,
                rain = 0.9
            }
        },
        
        -- Special Challenge Event
        special_challenge = {
            name = "Special Challenge",
            description = "Complete a series of challenging objectives!",
            type = 'special_challenge',
            duration = 2400000, -- 40 minutes
            cooldown = 7200000, -- 2 hours
            priority = 3,
            maxPlayers = 6,
            requirements = {
                minPlayers = 2,
                minLevel = 2
            },
            objectives = {
                {
                    id = 'complete_challenges',
                    type = 'challenge',
                    name = 'Complete Challenges',
                    description = 'Complete all challenge objectives',
                    challenges = {
                        'speed_run',
                        'precision_shot',
                        'stealth_infiltration',
                        'vehicle_mastery',
                        'team_coordination'
                    },
                    required = true,
                    rewards = {
                        influence = 150,
                        experience = 300
                    }
                }
            },
            rewards = {
                influence = 400,
                experience = 800,
                money = 20000,
                specialReward = 'challenge_badge'
            }
        },
        
        -- Team War Event
        team_war = {
            name = "Team War",
            description = "Teams are fighting for control! Choose your side!",
            type = 'team_war',
            duration = 1800000, -- 30 minutes
            cooldown = 5400000, -- 1.5 hours
            priority = 4,
            maxPlayers = 16,
            requirements = {
                minPlayers = 4,
                minLevel = 2
            },
            objectives = {
                {
                    id = 'win_war',
                    type = 'team_competition',
                    name = 'Win Team War',
                    description = 'Your team must achieve the highest score',
                    scoring = {
                        eliminations = 10,
                        captures = 50,
                        objectives = 25
                    },
                    required = true,
                    rewards = {
                        influence = 200,
                        experience = 400
                    }
                }
            },
            rewards = {
                influence = 500,
                experience = 1000,
                money = 25000,
                specialReward = 'war_victory_medal'
            }
        },
        
        -- Resource Rush Event
        resource_rush = {
            name = "Resource Rush",
            description = "Valuable resources are scattered across the district!",
            type = 'resource_rush',
            duration = 1200000, -- 20 minutes
            cooldown = 3600000, -- 1 hour
            priority = 2,
            maxPlayers = 12,
            requirements = {
                minPlayers = 2,
                minLevel = 1
            },
            objectives = {
                {
                    id = 'collect_resources',
                    type = 'collection',
                    name = 'Collect Resources',
                    description = 'Collect as many resources as possible',
                    targetCount = 10,
                    required = true,
                    rewards = {
                        influence = 100,
                        experience = 200
                    }
                },
                {
                    id = 'secure_resources',
                    type = 'defense',
                    name = 'Secure Resources',
                    description = 'Defend collected resources from other players',
                    duration = 300000, -- 5 minutes
                    required = false,
                    rewards = {
                        influence = 75,
                        experience = 150
                    }
                }
            },
            rewards = {
                influence = 300,
                experience = 600,
                money = 18000,
                specialReward = 'resource_pack'
            },
            spawns = {
                resources = {
                    { model = 'prop_gold_bar_01', count = 15, coords = nil },
                    { model = 'prop_diamond_01', count = 8, coords = nil },
                    { model = 'prop_cash_pile_01', count = 12, coords = nil }
                }
            }
        }
    },
    
    -- Event Scheduling
    schedule = {
        enabled = true,
        minInterval = 300000, -- 5 minutes
        maxInterval = 1800000, -- 30 minutes
        lastEvent = 0,
        nextEvent = 0,
        eventQueue = {},
        activeEventCount = 0,
        maxActiveEvents = 3
    },
    
    -- Event Statistics
    statistics = {
        totalEvents = 0,
        completedEvents = 0,
        failedEvents = 0,
        totalParticipants = 0,
        totalRewards = {
            influence = 0,
            experience = 0,
            money = 0
        }
    }
}

-- Event Creation Functions
local function CreateEventFromTemplate(template, districtId, coords, customData)
    local event = {
        id = 'event_' .. GetGameTimer(),
        name = template.name,
        description = template.description,
        type = template.type,
        template = template.name,
        districtId = districtId,
        coords = coords or { x = 0, y = 0, z = 0 },
        state = DynamicEventsSystem.eventStates.SCHEDULED,
        priority = template.priority,
        duration = template.duration,
        cooldown = template.cooldown,
        startTime = 0,
        endTime = 0,
        maxPlayers = template.maxPlayers,
        requirements = template.requirements,
        objectives = {},
        rewards = template.rewards,
        participants = {},
        progress = {},
        spawns = template.spawns,
        customData = customData or {},
        weather = template.weather
    }
    
    -- Copy and customize objectives
    for _, objective in ipairs(template.objectives) do
        local newObjective = {}
        for key, value in pairs(objective) do
            newObjective[key] = value
        end
        newObjective.id = objective.id .. '_' .. event.id
        newObjective.completed = false
        newObjective.progress = 0
        table.insert(event.objectives, newObjective)
    end
    
    -- Customize spawns with coordinates
    if event.spawns then
        for spawnType, spawns in pairs(event.spawns) do
            if type(spawns) == 'table' then
                for _, spawn in ipairs(spawns) do
                    if spawn.coords == nil then
                        spawn.coords = coords
                    end
                end
            elseif spawns.coords == nil then
                spawns.coords = coords
            end
        end
    end
    
    return event
end

-- Event Scheduling Functions
local function ScheduleEvent(event, delay)
    event.scheduledTime = GetGameTimer() + (delay or 0)
    event.state = DynamicEventsSystem.eventStates.SCHEDULED
    
    table.insert(DynamicEventsSystem.scheduledEvents, event)
    
    -- Sort by priority and scheduled time
    table.sort(DynamicEventsSystem.scheduledEvents, function(a, b)
        if a.priority == b.priority then
            return a.scheduledTime < b.scheduledTime
        end
        return a.priority > b.priority
    end)
    
    return event.id
end

local function StartEvent(eventId)
    local event = nil
    
    -- Find event in scheduled events
    for i, scheduledEvent in ipairs(DynamicEventsSystem.scheduledEvents) do
        if scheduledEvent.id == eventId then
            event = scheduledEvent
            table.remove(DynamicEventsSystem.scheduledEvents, i)
            break
        end
    end
    
    -- Find event in active events
    if not event then
        event = DynamicEventsSystem.activeEvents[eventId]
    end
    
    if not event then
        return false, 'Event not found'
    end
    
    -- Check requirements
    if event.requirements then
        local playerCount = 0
        for playerId, _ in pairs(event.participants) do
            playerCount = playerCount + 1
        end
        
        if event.requirements.minPlayers and playerCount < event.requirements.minPlayers then
            return false, 'Not enough players'
        end
    end
    
    -- Start event
    event.state = DynamicEventsSystem.eventStates.ACTIVE
    event.startTime = GetGameTimer()
    event.endTime = event.startTime + event.duration
    
    DynamicEventsSystem.activeEvents[eventId] = event
    DynamicEventsSystem.schedule.activeEventCount = DynamicEventsSystem.schedule.activeEventCount + 1
    DynamicEventsSystem.statistics.totalEvents = DynamicEventsSystem.statistics.totalEvents + 1
    
    -- Initialize objectives
    for _, objective in ipairs(event.objectives) do
        objective.completed = false
        objective.progress = 0
        objective.startTime = GetGameTimer()
    end
    
    return true, 'Event started'
end

-- Event Management Functions
local function UpdateEventProgress(eventId, playerId, objectiveId, progress)
    local event = DynamicEventsSystem.activeEvents[eventId]
    if not event or event.state ~= DynamicEventsSystem.eventStates.ACTIVE then
        return false, 'Event not active'
    end
    
    -- Find objective
    local objective = nil
    for _, obj in ipairs(event.objectives) do
        if obj.id == objectiveId then
            objective = obj
            break
        end
    end
    
    if not objective then
        return false, 'Objective not found'
    end
    
    -- Update progress
    objective.progress = progress
    
    -- Check if objective is completed
    if objective.type == 'elimination' then
        if progress >= objective.targetCount then
            objective.completed = true
        end
    elseif objective.type == 'collection' then
        if progress >= objective.targetCount then
            objective.completed = true
        end
    elseif objective.type == 'defense' then
        if progress >= objective.duration then
            objective.completed = true
        end
    elseif objective.type == 'survival' then
        if progress >= objective.duration then
            objective.completed = true
        end
    elseif objective.type == 'boss_fight' then
        if progress >= objective.bossHealth then
            objective.completed = true
        end
    elseif objective.type == 'challenge' then
        if progress >= #objective.challenges then
            objective.completed = true
        end
    elseif objective.type == 'team_competition' then
        -- Team competition is evaluated at the end
        objective.progress = progress
    end
    
    -- Update player progress
    if not event.participants[playerId] then
        event.participants[playerId] = {}
    end
    event.participants[playerId].progress = event.participants[playerId].progress or {}
    event.participants[playerId].progress[objectiveId] = progress
    
    -- Check if all required objectives are completed
    local allCompleted = true
    for _, obj in ipairs(event.objectives) do
        if obj.required and not obj.completed then
            allCompleted = false
            break
        end
    end
    
    if allCompleted then
        CompleteEvent(eventId)
    end
    
    return true, 'Progress updated'
end

local function CompleteEvent(eventId)
    local event = DynamicEventsSystem.activeEvents[eventId]
    if not event then
        return false, 'Event not found'
    end
    
    event.state = DynamicEventsSystem.eventStates.COMPLETED
    event.endTime = GetGameTimer()
    
    -- Distribute rewards
    for playerId, participant in pairs(event.participants) do
        -- Calculate individual rewards based on participation
        local participationTime = GetGameTimer() - event.startTime
        local participationRatio = math.min(participationTime / event.duration, 1.0)
        
        local playerRewards = {}
        for rewardType, amount in pairs(event.rewards) do
            if type(amount) == 'number' then
                playerRewards[rewardType] = math.floor(amount * participationRatio)
            else
                playerRewards[rewardType] = amount
            end
        end
        
        -- Trigger reward distribution
        TriggerEvent('dz:event:rewards', playerId, eventId, playerRewards)
    end
    
    -- Update statistics
    DynamicEventsSystem.statistics.completedEvents = DynamicEventsSystem.statistics.completedEvents + 1
    DynamicEventsSystem.statistics.totalParticipants = DynamicEventsSystem.statistics.totalParticipants + #event.participants
    
    -- Move to history
    DynamicEventsSystem.eventHistory[eventId] = event
    DynamicEventsSystem.activeEvents[eventId] = nil
    DynamicEventsSystem.schedule.activeEventCount = DynamicEventsSystem.schedule.activeEventCount - 1
    
    return true, 'Event completed'
end

local function FailEvent(eventId, reason)
    local event = DynamicEventsSystem.activeEvents[eventId]
    if not event then
        return false, 'Event not found'
    end
    
    event.state = DynamicEventsSystem.eventStates.FAILED
    event.endTime = GetGameTimer()
    event.failReason = reason
    
    -- Update statistics
    DynamicEventsSystem.statistics.failedEvents = DynamicEventsSystem.statistics.failedEvents + 1
    
    -- Move to history
    DynamicEventsSystem.eventHistory[eventId] = event
    DynamicEventsSystem.activeEvents[eventId] = nil
    DynamicEventsSystem.schedule.activeEventCount = DynamicEventsSystem.schedule.activeEventCount - 1
    
    return true, 'Event failed'
end

-- Event Generation Functions
local function GenerateRandomEvent(districtId, coords)
    local availableTemplates = {}
    
    -- Get available templates based on district and time
    for templateName, template in pairs(DynamicEventsSystem.eventTemplates) do
        -- Check if template is available (not on cooldown)
        local lastEvent = DynamicEventsSystem.statistics.lastEventByType and DynamicEventsSystem.statistics.lastEventByType[templateName]
        if not lastEvent or (GetGameTimer() - lastEvent) > template.cooldown then
            table.insert(availableTemplates, templateName)
        end
    end
    
    if #availableTemplates == 0 then
        return nil
    end
    
    -- Select random template
    local selectedTemplate = availableTemplates[math.random(1, #availableTemplates)]
    local template = DynamicEventsSystem.eventTemplates[selectedTemplate]
    
    -- Create event
    local event = CreateEventFromTemplate(template, districtId, coords)
    
    -- Schedule with random delay
    local delay = math.random(30000, 120000) -- 30 seconds to 2 minutes
    ScheduleEvent(event, delay)
    
    return event.id
end

local function GenerateScheduledEvents()
    local currentTime = GetGameTimer()
    
    -- Check if it's time for a scheduled event
    if currentTime < DynamicEventsSystem.schedule.nextEvent then
        return
    end
    
    -- Generate random interval for next event
    local interval = math.random(DynamicEventsSystem.schedule.minInterval, DynamicEventsSystem.schedule.maxInterval)
    DynamicEventsSystem.schedule.nextEvent = currentTime + interval
    
    -- Check if we can have more active events
    if DynamicEventsSystem.schedule.activeEventCount >= DynamicEventsSystem.schedule.maxActiveEvents then
        return
    end
    
    -- Generate event for random district
    local districts = {}
    for districtId, _ in pairs(Config.districts) do
        table.insert(districts, districtId)
    end
    
    if #districts > 0 then
        local randomDistrict = districts[math.random(1, #districts)]
        local district = Config.districts[randomDistrict]
        
        if district then
            local coords = {
                x = district.center.x + (math.random() - 0.5) * district.radius * 0.8,
                y = district.center.y + (math.random() - 0.5) * district.radius * 0.8,
                z = district.center.z
            }
            
            local eventId = GenerateRandomEvent(randomDistrict, coords)
            if eventId then
                print('^2[District Zero] ^7Scheduled random event: ' .. eventId .. ' in district: ' .. randomDistrict)
            end
        end
    end
end

-- Event Cleanup
local function CleanupExpiredEvents()
    local currentTime = GetGameTimer()
    local toRemove = {}
    
    for eventId, event in pairs(DynamicEventsSystem.activeEvents) do
        if event.state == DynamicEventsSystem.eventStates.ACTIVE and event.endTime < currentTime then
            FailEvent(eventId, 'Time limit exceeded')
            table.insert(toRemove, eventId)
        end
    end
    
    for _, eventId in ipairs(toRemove) do
        DynamicEventsSystem.activeEvents[eventId] = nil
    end
    
    return #toRemove
end

-- Dynamic Events System Methods
DynamicEventsSystem.CreateEventFromTemplate = CreateEventFromTemplate
DynamicEventsSystem.ScheduleEvent = ScheduleEvent
DynamicEventsSystem.StartEvent = StartEvent
DynamicEventsSystem.UpdateEventProgress = UpdateEventProgress
DynamicEventsSystem.CompleteEvent = CompleteEvent
DynamicEventsSystem.FailEvent = FailEvent
DynamicEventsSystem.GenerateRandomEvent = GenerateRandomEvent
DynamicEventsSystem.GenerateScheduledEvents = GenerateScheduledEvents
DynamicEventsSystem.CleanupExpiredEvents = CleanupExpiredEvents

-- Cleanup Thread
CreateThread(function()
    while true do
        Wait(30000) -- Every 30 seconds
        
        -- Generate scheduled events
        GenerateScheduledEvents()
        
        -- Clean up expired events
        local cleanedCount = CleanupExpiredEvents()
        if cleanedCount > 0 then
            print('^3[District Zero] ^7Cleaned up ' .. cleanedCount .. ' expired events')
        end
    end
end)

-- Exports
exports('CreateEventFromTemplate', CreateEventFromTemplate)
exports('ScheduleEvent', ScheduleEvent)
exports('StartEvent', StartEvent)
exports('UpdateEventProgress', UpdateEventProgress)
exports('CompleteEvent', CompleteEvent)
exports('FailEvent', FailEvent)
exports('GenerateRandomEvent', GenerateRandomEvent)
exports('GenerateScheduledEvents', GenerateScheduledEvents)
exports('CleanupExpiredEvents', CleanupExpiredEvents)

return DynamicEventsSystem 