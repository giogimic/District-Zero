-- District Zero Advanced Mission System
-- Version: 1.0.0

local AdvancedMissionSystem = {
    -- Mission Types
    missionTypes = {
        CAPTURE = 'capture',
        ELIMINATE = 'eliminate',
        ESCORT = 'escort',
        DEFEND = 'defend',
        INFILTRATE = 'infiltrate',
        BOSS = 'boss',
        CHAIN = 'chain',
        DYNAMIC = 'dynamic',
        EVENT = 'event'
    },
    
    -- Objective Types
    objectiveTypes = {
        LOCATION = 'location',
        INTERACTION = 'interaction',
        COLLECTION = 'collection',
        ELIMINATION = 'elimination',
        ESCORT = 'escort',
        DEFENSE = 'defense',
        HACK = 'hack',
        BOSS_FIGHT = 'boss_fight',
        TIMED = 'timed',
        CONDITIONAL = 'conditional'
    },
    
    -- Difficulty Levels
    difficulties = {
        EASY = { multiplier = 1.0, rewards = 1.0, enemyCount = 1.0 },
        NORMAL = { multiplier = 1.5, rewards = 1.5, enemyCount = 1.2 },
        HARD = { multiplier = 2.0, rewards = 2.0, enemyCount = 1.5 },
        EXPERT = { multiplier = 3.0, rewards = 3.0, enemyCount = 2.0 },
        NIGHTMARE = { multiplier = 5.0, rewards = 5.0, enemyCount = 3.0 }
    },
    
    -- Mission States
    states = {
        AVAILABLE = 'available',
        ACTIVE = 'active',
        COMPLETED = 'completed',
        FAILED = 'failed',
        EXPIRED = 'expired',
        CHAIN_WAITING = 'chain_waiting'
    },
    
    -- Active Missions
    activeMissions = {},
    
    -- Mission Chains
    missionChains = {},
    
    -- Dynamic Events
    dynamicEvents = {},
    
    -- Boss Encounters
    bossEncounters = {},
    
    -- Mission Templates
    missionTemplates = {
        -- Capture Mission Template
        capture = {
            name = "District Capture",
            description = "Capture and secure the target district",
            type = 'capture',
            objectives = {
                {
                    id = 'capture_point',
                    type = 'location',
                    name = 'Capture Control Point',
                    description = 'Reach and capture the control point',
                    coords = nil, -- Set dynamically
                    radius = 50,
                    required = true,
                    timeLimit = 300, -- 5 minutes
                    rewards = {
                        influence = 50,
                        experience = 100
                    }
                }
            },
            rewards = {
                influence = 100,
                experience = 200,
                money = 5000
            },
            difficulty = 'normal',
            timeLimit = 900, -- 15 minutes
            maxPlayers = 4,
            requirements = {
                level = 1,
                team = true
            }
        },
        
        -- Elimination Mission Template
        eliminate = {
            name = "Target Elimination",
            description = "Eliminate all hostile targets in the area",
            type = 'eliminate',
            objectives = {
                {
                    id = 'eliminate_targets',
                    type = 'elimination',
                    name = 'Eliminate Targets',
                    description = 'Eliminate all marked targets',
                    targetCount = 5,
                    targetTypes = { 'npc', 'vehicle' },
                    radius = 200,
                    required = true,
                    timeLimit = 600, -- 10 minutes
                    rewards = {
                        influence = 75,
                        experience = 150
                    }
                }
            },
            rewards = {
                influence = 150,
                experience = 300,
                money = 7500
            },
            difficulty = 'normal',
            timeLimit = 1200, -- 20 minutes
            maxPlayers = 6,
            requirements = {
                level = 2,
                team = true
            }
        },
        
        -- Escort Mission Template
        escort = {
            name = "VIP Escort",
            description = "Escort the VIP to the safe location",
            type = 'escort',
            objectives = {
                {
                    id = 'escort_vip',
                    type = 'escort',
                    name = 'Escort VIP',
                    description = 'Protect and escort the VIP to safety',
                    startCoords = nil, -- Set dynamically
                    endCoords = nil, -- Set dynamically
                    vipHealth = 100,
                    required = true,
                    timeLimit = 900, -- 15 minutes
                    rewards = {
                        influence = 100,
                        experience = 200
                    }
                }
            },
            rewards = {
                influence = 200,
                experience = 400,
                money = 10000
            },
            difficulty = 'hard',
            timeLimit = 1800, -- 30 minutes
            maxPlayers = 4,
            requirements = {
                level = 3,
                team = true
            }
        },
        
        -- Defense Mission Template
        defend = {
            name = "Point Defense",
            description = "Defend the control point from enemy waves",
            type = 'defend',
            objectives = {
                {
                    id = 'defend_point',
                    type = 'defense',
                    name = 'Defend Control Point',
                    description = 'Defend the point for the required time',
                    coords = nil, -- Set dynamically
                    radius = 100,
                    defenseTime = 300, -- 5 minutes
                    waveCount = 3,
                    required = true,
                    rewards = {
                        influence = 125,
                        experience = 250
                    }
                }
            },
            rewards = {
                influence = 250,
                experience = 500,
                money = 12500
            },
            difficulty = 'hard',
            timeLimit = 2400, -- 40 minutes
            maxPlayers = 6,
            requirements = {
                level = 4,
                team = true
            }
        },
        
        -- Boss Mission Template
        boss = {
            name = "Boss Encounter",
            description = "Face off against a powerful enemy",
            type = 'boss',
            objectives = {
                {
                    id = 'defeat_boss',
                    type = 'boss_fight',
                    name = 'Defeat Boss',
                    description = 'Eliminate the boss enemy',
                    bossType = 'heavy_gunner',
                    bossHealth = 1000,
                    bossCoords = nil, -- Set dynamically
                    radius = 150,
                    required = true,
                    timeLimit = 1800, -- 30 minutes
                    rewards = {
                        influence = 200,
                        experience = 400
                    }
                }
            },
            rewards = {
                influence = 400,
                experience = 800,
                money = 20000,
                specialReward = 'boss_weapon'
            },
            difficulty = 'expert',
            timeLimit = 3600, -- 60 minutes
            maxPlayers = 8,
            requirements = {
                level = 5,
                team = true
            }
        }
    },
    
    -- Mission Chain Templates
    chainTemplates = {
        district_liberation = {
            name = "District Liberation",
            description = "Complete series of missions to liberate the district",
            missions = {
                'infiltrate_district',
                'eliminate_guards',
                'capture_control',
                'defend_position',
                'boss_encounter'
            },
            rewards = {
                influence = 1000,
                experience = 2000,
                money = 50000,
                specialReward = 'district_access'
            },
            timeLimit = 7200, -- 2 hours
            difficulty = 'expert'
        },
        
        criminal_network = {
            name = "Criminal Network",
            description = "Take down a criminal network",
            missions = {
                'gather_intel',
                'infiltrate_hideout',
                'eliminate_leaders',
                'secure_evidence',
                'escape_pursuit'
            },
            rewards = {
                influence = 800,
                experience = 1600,
                money = 40000,
                specialReward = 'network_intel'
            },
            timeLimit = 5400, -- 1.5 hours
            difficulty = 'hard'
        }
    }
}

-- Mission Creation Functions
local function CreateMissionFromTemplate(template, difficulty, coords, customData)
    local mission = {
        id = 'mission_' .. GetGameTimer(),
        name = template.name,
        description = template.description,
        type = template.type,
        difficulty = difficulty or template.difficulty,
        coords = coords or template.coords,
        objectives = {},
        rewards = {},
        state = AdvancedMissionSystem.states.AVAILABLE,
        startTime = 0,
        endTime = 0,
        timeLimit = template.timeLimit,
        maxPlayers = template.maxPlayers,
        requirements = template.requirements,
        players = {},
        progress = {},
        customData = customData or {}
    }
    
    -- Apply difficulty multiplier
    local difficultyConfig = AdvancedMissionSystem.difficulties[difficulty]
    if difficultyConfig then
        mission.timeLimit = math.floor(mission.timeLimit * difficultyConfig.multiplier)
        
        -- Scale rewards
        for rewardType, amount in pairs(template.rewards) do
            if type(amount) == 'number' then
                mission.rewards[rewardType] = math.floor(amount * difficultyConfig.rewards)
            else
                mission.rewards[rewardType] = amount
            end
        end
    else
        mission.rewards = template.rewards
    end
    
    -- Copy and customize objectives
    for _, objective in ipairs(template.objectives) do
        local newObjective = {}
        for key, value in pairs(objective) do
            if key == 'coords' and coords then
                newObjective[key] = coords
            else
                newObjective[key] = value
            end
        end
        newObjective.id = objective.id .. '_' .. mission.id
        newObjective.completed = false
        newObjective.progress = 0
        table.insert(mission.objectives, newObjective)
    end
    
    return mission
end

-- Mission Chain Functions
local function CreateMissionChain(chainTemplate, difficulty, startCoords)
    local chain = {
        id = 'chain_' .. GetGameTimer(),
        name = chainTemplate.name,
        description = chainTemplate.description,
        template = chainTemplate.name,
        difficulty = difficulty or chainTemplate.difficulty,
        startCoords = startCoords,
        missions = {},
        currentMission = 1,
        state = AdvancedMissionSystem.states.AVAILABLE,
        startTime = 0,
        endTime = 0,
        timeLimit = chainTemplate.timeLimit,
        rewards = chainTemplate.rewards,
        players = {},
        progress = {}
    }
    
    -- Create individual missions for the chain
    for i, missionType in ipairs(chainTemplate.missions) do
        local missionTemplate = AdvancedMissionSystem.missionTemplates[missionType]
        if missionTemplate then
            local mission = CreateMissionFromTemplate(missionTemplate, difficulty, startCoords)
            mission.chainId = chain.id
            mission.chainOrder = i
            mission.state = AdvancedMissionSystem.states.CHAIN_WAITING
            table.insert(chain.missions, mission)
        end
    end
    
    return chain
end

-- Dynamic Mission Generation
local function GenerateDynamicMission(districtId, playerLevel, teamSize)
    local availableTypes = {}
    
    -- Determine available mission types based on player level
    if playerLevel >= 1 then
        table.insert(availableTypes, 'capture')
    end
    if playerLevel >= 2 then
        table.insert(availableTypes, 'eliminate')
    end
    if playerLevel >= 3 then
        table.insert(availableTypes, 'escort')
    end
    if playerLevel >= 4 then
        table.insert(availableTypes, 'defend')
    end
    if playerLevel >= 5 then
        table.insert(availableTypes, 'boss')
    end
    
    -- Select random mission type
    local selectedType = availableTypes[math.random(1, #availableTypes)]
    local template = AdvancedMissionSystem.missionTemplates[selectedType]
    
    if not template then
        return nil
    end
    
    -- Determine difficulty based on player level and team size
    local difficulty = 'normal'
    if playerLevel >= 8 and teamSize >= 4 then
        difficulty = 'expert'
    elseif playerLevel >= 6 and teamSize >= 3 then
        difficulty = 'hard'
    elseif playerLevel >= 4 and teamSize >= 2 then
        difficulty = 'normal'
    else
        difficulty = 'easy'
    end
    
    -- Generate random coordinates within district
    local district = Config.districts[districtId]
    if not district then
        return nil
    end
    
    local coords = {
        x = district.center.x + (math.random() - 0.5) * district.radius * 0.8,
        y = district.center.y + (math.random() - 0.5) * district.radius * 0.8,
        z = district.center.z
    }
    
    -- Create mission with custom data
    local customData = {
        districtId = districtId,
        generated = true,
        playerLevel = playerLevel,
        teamSize = teamSize
    }
    
    return CreateMissionFromTemplate(template, difficulty, coords, customData)
end

-- Mission Management Functions
local function StartMission(missionId, playerId)
    local mission = AdvancedMissionSystem.activeMissions[missionId]
    if not mission then
        return false, 'Mission not found'
    end
    
    if mission.state ~= AdvancedMissionSystem.states.AVAILABLE then
        return false, 'Mission not available'
    end
    
    -- Check requirements
    if mission.requirements then
        if mission.requirements.level and playerLevel < mission.requirements.level then
            return false, 'Level requirement not met'
        end
        if mission.requirements.team and not playerTeam then
            return false, 'Team requirement not met'
        end
    end
    
    -- Start mission
    mission.state = AdvancedMissionSystem.states.ACTIVE
    mission.startTime = GetGameTimer()
    mission.endTime = mission.startTime + (mission.timeLimit * 1000)
    mission.players[playerId] = {
        joinTime = GetGameTimer(),
        progress = {}
    }
    
    -- Initialize objectives
    for _, objective in ipairs(mission.objectives) do
        objective.completed = false
        objective.progress = 0
        objective.startTime = GetGameTimer()
    end
    
    return true, 'Mission started'
end

local function UpdateMissionProgress(missionId, playerId, objectiveId, progress)
    local mission = AdvancedMissionSystem.activeMissions[missionId]
    if not mission or mission.state ~= AdvancedMissionSystem.states.ACTIVE then
        return false, 'Mission not active'
    end
    
    -- Find objective
    local objective = nil
    for _, obj in ipairs(mission.objectives) do
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
    elseif objective.type == 'location' then
        if progress >= 100 then
            objective.completed = true
        end
    elseif objective.type == 'escort' then
        if progress >= 100 then
            objective.completed = true
        end
    elseif objective.type == 'defense' then
        if progress >= objective.defenseTime then
            objective.completed = true
        end
    elseif objective.type == 'boss_fight' then
        if progress >= objective.bossHealth then
            objective.completed = true
        end
    end
    
    -- Update player progress
    if not mission.players[playerId] then
        mission.players[playerId] = {}
    end
    mission.players[playerId].progress[objectiveId] = progress
    
    -- Check if all objectives are completed
    local allCompleted = true
    for _, obj in ipairs(mission.objectives) do
        if obj.required and not obj.completed then
            allCompleted = false
            break
        end
    end
    
    if allCompleted then
        CompleteMission(missionId)
    end
    
    return true, 'Progress updated'
end

local function CompleteMission(missionId)
    local mission = AdvancedMissionSystem.activeMissions[missionId]
    if not mission then
        return false, 'Mission not found'
    end
    
    mission.state = AdvancedMissionSystem.states.COMPLETED
    mission.endTime = GetGameTimer()
    
    -- Distribute rewards
    for playerId, playerData in pairs(mission.players) do
        -- Calculate individual rewards based on participation
        local participationTime = GetGameTimer() - playerData.joinTime
        local participationRatio = math.min(participationTime / (mission.endTime - mission.startTime), 1.0)
        
        local playerRewards = {}
        for rewardType, amount in pairs(mission.rewards) do
            if type(amount) == 'number' then
                playerRewards[rewardType] = math.floor(amount * participationRatio)
            else
                playerRewards[rewardType] = amount
            end
        end
        
        -- Trigger reward distribution
        TriggerEvent('dz:mission:rewards', playerId, missionId, playerRewards)
    end
    
    -- Handle mission chains
    if mission.chainId then
        local chain = AdvancedMissionSystem.missionChains[mission.chainId]
        if chain then
            chain.currentMission = chain.currentMission + 1
            if chain.currentMission <= #chain.missions then
                -- Start next mission in chain
                local nextMission = chain.missions[chain.currentMission]
                nextMission.state = AdvancedMissionSystem.states.AVAILABLE
                AdvancedMissionSystem.activeMissions[nextMission.id] = nextMission
            else
                -- Complete chain
                CompleteMissionChain(mission.chainId)
            end
        end
    end
    
    return true, 'Mission completed'
end

local function FailMission(missionId, reason)
    local mission = AdvancedMissionSystem.activeMissions[missionId]
    if not mission then
        return false, 'Mission not found'
    end
    
    mission.state = AdvancedMissionSystem.states.FAILED
    mission.endTime = GetGameTimer()
    mission.failReason = reason
    
    -- Notify all players
    for playerId, _ in pairs(mission.players) do
        TriggerClientEvent('dz:notification:show', playerId, {
            type = 'error',
            title = 'Mission Failed',
            message = reason or 'Mission failed',
            duration = 5000
        })
    end
    
    return true, 'Mission failed'
end

local function CompleteMissionChain(chainId)
    local chain = AdvancedMissionSystem.missionChains[chainId]
    if not chain then
        return false, 'Chain not found'
    end
    
    chain.state = AdvancedMissionSystem.states.COMPLETED
    chain.endTime = GetGameTimer()
    
    -- Distribute chain rewards
    for playerId, _ in pairs(chain.players) do
        TriggerEvent('dz:mission:chain_rewards', playerId, chainId, chain.rewards)
    end
    
    return true, 'Chain completed'
end

-- Mission Cleanup
local function CleanupExpiredMissions()
    local currentTime = GetGameTimer()
    local toRemove = {}
    
    for missionId, mission in pairs(AdvancedMissionSystem.activeMissions) do
        if mission.state == AdvancedMissionSystem.states.ACTIVE and mission.endTime < currentTime then
            FailMission(missionId, 'Time limit exceeded')
            table.insert(toRemove, missionId)
        end
    end
    
    for _, missionId in ipairs(toRemove) do
        AdvancedMissionSystem.activeMissions[missionId] = nil
    end
    
    return #toRemove
end

-- Advanced Mission System Methods
AdvancedMissionSystem.CreateMissionFromTemplate = CreateMissionFromTemplate
AdvancedMissionSystem.CreateMissionChain = CreateMissionChain
AdvancedMissionSystem.GenerateDynamicMission = GenerateDynamicMission
AdvancedMissionSystem.StartMission = StartMission
AdvancedMissionSystem.UpdateMissionProgress = UpdateMissionProgress
AdvancedMissionSystem.CompleteMission = CompleteMission
AdvancedMissionSystem.FailMission = FailMission
AdvancedMissionSystem.CompleteMissionChain = CompleteMissionChain
AdvancedMissionSystem.CleanupExpiredMissions = CleanupExpiredMissions

-- Cleanup Thread
CreateThread(function()
    while true do
        Wait(30000) -- Every 30 seconds
        
        -- Clean up expired missions
        local cleanedCount = CleanupExpiredMissions()
        if cleanedCount > 0 then
            print('^3[District Zero] ^7Cleaned up ' .. cleanedCount .. ' expired missions')
        end
    end
end)

-- Exports
exports('CreateMissionFromTemplate', CreateMissionFromTemplate)
exports('CreateMissionChain', CreateMissionChain)
exports('GenerateDynamicMission', GenerateDynamicMission)
exports('StartMission', StartMission)
exports('UpdateMissionProgress', UpdateMissionProgress)
exports('CompleteMission', CompleteMission)
exports('FailMission', FailMission)
exports('CompleteMissionChain', CompleteMissionChain)
exports('CleanupExpiredMissions', CleanupExpiredMissions)

return AdvancedMissionSystem 