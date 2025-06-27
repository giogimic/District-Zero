-- District Zero Achievement System
-- Version: 1.0.0

local AchievementSystem = {
    -- Achievement Categories
    categories = {
        COMBAT = 'combat',
        EXPLORATION = 'exploration',
        TEAMWORK = 'teamwork',
        LEADERSHIP = 'leadership',
        COLLECTION = 'collection',
        SOCIAL = 'social',
        MASTERY = 'mastery',
        SPECIAL = 'special'
    },
    
    -- Achievement States
    states = {
        LOCKED = 'locked',
        IN_PROGRESS = 'in_progress',
        COMPLETED = 'completed',
        MASTERED = 'mastered'
    },
    
    -- Achievement Types
    types = {
        COUNTER = 'counter',
        MILESTONE = 'milestone',
        CHAIN = 'chain',
        TIME_BASED = 'time_based',
        CONDITIONAL = 'conditional'
    },
    
    -- Active Achievements
    activeAchievements = {},
    
    -- Player Progress
    playerProgress = {},
    
    -- Achievement Templates
    achievementTemplates = {
        -- Combat Achievements
        combat_kills = {
            id = 'combat_kills',
            name = 'Combat Master',
            description = 'Eliminate opponents in combat',
            category = 'combat',
            type = 'counter',
            icon = '🎯',
            color = '#ff4444',
            requirements = {
                { type = 'kills', target = 100, description = 'Eliminate 100 opponents' }
            },
            rewards = {
                { type = 'influence', amount = 500 },
                { type = 'experience', amount = 1000 },
                { type = 'money', amount = 25000 }
            },
            milestones = {
                { target = 10, reward = { type = 'influence', amount = 50 } },
                { target = 25, reward = { type = 'influence', amount = 100 } },
                { target = 50, reward = { type = 'influence', amount = 200 } },
                { target = 100, reward = { type = 'influence', amount = 500 } }
            },
            maxProgress = 1000
        },
        
        combat_survivor = {
            id = 'combat_survivor',
            name = 'Survivor',
            description = 'Survive intense combat situations',
            category = 'combat',
            type = 'counter',
            icon = '🛡️',
            color = '#44ff44',
            requirements = {
                { type = 'survival_time', target = 3600, description = 'Survive for 1 hour in combat zones' }
            },
            rewards = {
                { type = 'influence', amount = 300 },
                { type = 'experience', amount = 800 },
                { type = 'money', amount = 15000 }
            },
            milestones = {
                { target = 300, reward = { type = 'influence', amount = 30 } },
                { target = 900, reward = { type = 'influence', amount = 60 } },
                { target = 1800, reward = { type = 'influence', amount = 120 } },
                { target = 3600, reward = { type = 'influence', amount = 300 } }
            },
            maxProgress = 7200
        },
        
        -- Exploration Achievements
        exploration_districts = {
            id = 'exploration_districts',
            name = 'District Explorer',
            description = 'Visit all districts in the city',
            category = 'exploration',
            type = 'milestone',
            icon = '🗺️',
            color = '#4444ff',
            requirements = {
                { type = 'districts_visited', target = 10, description = 'Visit all 10 districts' }
            },
            rewards = {
                { type = 'influence', amount = 400 },
                { type = 'experience', amount = 1200 },
                { type = 'money', amount = 30000 }
            },
            milestones = {
                { target = 2, reward = { type = 'influence', amount = 40 } },
                { target = 5, reward = { type = 'influence', amount = 100 } },
                { target = 8, reward = { type = 'influence', amount = 200 } },
                { target = 10, reward = { type = 'influence', amount = 400 } }
            },
            maxProgress = 10
        },
        
        exploration_distance = {
            id = 'exploration_distance',
            name = 'World Traveler',
            description = 'Travel great distances across the city',
            category = 'exploration',
            type = 'counter',
            icon = '🚶',
            color = '#44ffff',
            requirements = {
                { type = 'distance_traveled', target = 50000, description = 'Travel 50,000 meters' }
            },
            rewards = {
                { type = 'influence', amount = 600 },
                { type = 'experience', amount = 1500 },
                { type = 'money', amount = 40000 }
            },
            milestones = {
                { target = 5000, reward = { type = 'influence', amount = 50 } },
                { target = 15000, reward = { type = 'influence', amount = 150 } },
                { target = 30000, reward = { type = 'influence', amount = 300 } },
                { target = 50000, reward = { type = 'influence', amount = 600 } }
            },
            maxProgress = 100000
        },
        
        -- Teamwork Achievements
        teamwork_captures = {
            id = 'teamwork_captures',
            name = 'Team Player',
            description = 'Participate in district captures with your team',
            category = 'teamwork',
            type = 'counter',
            icon = '🤝',
            color = '#ff8844',
            requirements = {
                { type = 'team_captures', target = 20, description = 'Participate in 20 team captures' }
            },
            rewards = {
                { type = 'influence', amount = 800 },
                { type = 'experience', amount = 2000 },
                { type = 'money', amount = 50000 }
            },
            milestones = {
                { target = 5, reward = { type = 'influence', amount = 80 } },
                { target = 10, reward = { type = 'influence', amount = 200 } },
                { target = 15, reward = { type = 'influence', amount = 400 } },
                { target = 20, reward = { type = 'influence', amount = 800 } }
            },
            maxProgress = 100
        },
        
        teamwork_missions = {
            id = 'teamwork_missions',
            name = 'Mission Specialist',
            description = 'Complete missions with your team',
            category = 'teamwork',
            type = 'counter',
            icon = '📋',
            color = '#8844ff',
            requirements = {
                { type = 'team_missions', target = 50, description = 'Complete 50 team missions' }
            },
            rewards = {
                { type = 'influence', amount = 1000 },
                { type = 'experience', amount = 2500 },
                { type = 'money', amount = 75000 }
            },
            milestones = {
                { target = 10, reward = { type = 'influence', amount = 100 } },
                { target = 25, reward = { type = 'influence', amount = 250 } },
                { target = 40, reward = { type = 'influence', amount = 500 } },
                { target = 50, reward = { type = 'influence', amount = 1000 } }
            },
            maxProgress = 200
        },
        
        -- Leadership Achievements
        leadership_team = {
            id = 'leadership_team',
            name = 'Team Leader',
            description = 'Lead a successful team',
            category = 'leadership',
            type = 'milestone',
            icon = '👑',
            color = '#ffff44',
            requirements = {
                { type = 'team_leadership_time', target = 7200, description = 'Lead a team for 2 hours' }
            },
            rewards = {
                { type = 'influence', amount = 1200 },
                { type = 'experience', amount = 3000 },
                { type = 'money', amount = 100000 }
            },
            milestones = {
                { target = 900, reward = { type = 'influence', amount = 120 } },
                { target = 1800, reward = { type = 'influence', amount = 300 } },
                { target = 3600, reward = { type = 'influence', amount = 600 } },
                { target = 7200, reward = { type = 'influence', amount = 1200 } }
            },
            maxProgress = 14400
        },
        
        leadership_wars = {
            id = 'leadership_wars',
            name = 'War Commander',
            description = 'Lead your team to victory in wars',
            category = 'leadership',
            type = 'counter',
            icon = '⚔️',
            color = '#ff4444',
            requirements = {
                { type = 'wars_won', target = 5, description = 'Win 5 team wars' }
            },
            rewards = {
                { type = 'influence', amount = 1500 },
                { type = 'experience', amount = 4000 },
                { type = 'money', amount = 150000 }
            },
            milestones = {
                { target = 1, reward = { type = 'influence', amount = 150 } },
                { target = 2, reward = { type = 'influence', amount = 300 } },
                { target = 3, reward = { type = 'influence', amount = 600 } },
                { target = 5, reward = { type = 'influence', amount = 1500 } }
            },
            maxProgress = 20
        },
        
        -- Collection Achievements
        collection_items = {
            id = 'collection_items',
            name = 'Collector',
            description = 'Collect various items throughout the city',
            category = 'collection',
            type = 'counter',
            icon = '📦',
            color = '#44ff88',
            requirements = {
                { type = 'items_collected', target = 100, description = 'Collect 100 unique items' }
            },
            rewards = {
                { type = 'influence', amount = 400 },
                { type = 'experience', amount = 1000 },
                { type = 'money', amount = 25000 }
            },
            milestones = {
                { target = 10, reward = { type = 'influence', amount = 40 } },
                { target = 25, reward = { type = 'influence', amount = 100 } },
                { target = 50, reward = { type = 'influence', amount = 200 } },
                { target = 100, reward = { type = 'influence', amount = 400 } }
            },
            maxProgress = 500
        },
        
        -- Social Achievements
        social_interactions = {
            id = 'social_interactions',
            name = 'Social Butterfly',
            description = 'Interact with other players',
            category = 'social',
            type = 'counter',
            icon = '💬',
            color = '#ff88ff',
            requirements = {
                { type = 'player_interactions', target = 200, description = 'Interact with 200 different players' }
            },
            rewards = {
                { type = 'influence', amount = 300 },
                { type = 'experience', amount = 800 },
                { type = 'money', amount = 20000 }
            },
            milestones = {
                { target = 25, reward = { type = 'influence', amount = 30 } },
                { target = 50, reward = { type = 'influence', amount = 75 } },
                { target = 100, reward = { type = 'influence', amount = 150 } },
                { target = 200, reward = { type = 'influence', amount = 300 } }
            },
            maxProgress = 1000
        },
        
        -- Mastery Achievements
        mastery_all_categories = {
            id = 'mastery_all_categories',
            name = 'Master of All',
            description = 'Complete achievements in all categories',
            category = 'mastery',
            type = 'milestone',
            icon = '🏆',
            color = '#ffff88',
            requirements = {
                { type = 'categories_mastered', target = 7, description = 'Master all 7 achievement categories' }
            },
            rewards = {
                { type = 'influence', amount = 5000 },
                { type = 'experience', amount = 10000 },
                { type = 'money', amount = 500000 },
                { type = 'special_title', value = 'Master of All' }
            },
            milestones = {
                { target = 2, reward = { type = 'influence', amount = 500 } },
                { target = 4, reward = { type = 'influence', amount = 1500 } },
                { target = 6, reward = { type = 'influence', amount = 3000 } },
                { target = 7, reward = { type = 'influence', amount = 5000 } }
            },
            maxProgress = 7
        },
        
        -- Special Achievements
        special_first_capture = {
            id = 'special_first_capture',
            name = 'First Blood',
            description = 'Capture your first district',
            category = 'special',
            type = 'milestone',
            icon = '🩸',
            color = '#ff0000',
            requirements = {
                { type = 'first_capture', target = 1, description = 'Capture your first district' }
            },
            rewards = {
                { type = 'influence', amount = 1000 },
                { type = 'experience', amount = 2000 },
                { type = 'money', amount = 50000 },
                { type = 'special_title', value = 'First Blood' }
            },
            milestones = {
                { target = 1, reward = { type = 'influence', amount = 1000 } }
            },
            maxProgress = 1
        },
        
        special_24_hours = {
            id = 'special_24_hours',
            name = 'Dedicated Player',
            description = 'Play for 24 hours total',
            category = 'special',
            type = 'counter',
            icon = '⏰',
            color = '#888888',
            requirements = {
                { type = 'total_playtime', target = 86400, description = 'Play for 24 hours total' }
            },
            rewards = {
                { type = 'influence', amount = 2000 },
                { type = 'experience', amount = 5000 },
                { type = 'money', amount = 100000 },
                { type = 'special_title', value = 'Dedicated' }
            },
            milestones = {
                { target = 3600, reward = { type = 'influence', amount = 200 } },
                { target = 7200, reward = { type = 'influence', amount = 500 } },
                { target = 14400, reward = { type = 'influence', amount = 1000 } },
                { target = 86400, reward = { type = 'influence', amount = 2000 } }
            },
            maxProgress = 172800
        }
    },
    
    -- Achievement Chains
    achievementChains = {
        combat_chain = {
            id = 'combat_chain',
            name = 'Combat Mastery Chain',
            description = 'Complete all combat achievements',
            achievements = {
                'combat_kills',
                'combat_survivor'
            },
            rewards = {
                { type = 'influence', amount = 1000 },
                { type = 'experience', amount = 2500 },
                { type = 'money', amount = 75000 },
                { type = 'special_title', value = 'Combat Master' }
            }
        },
        
        exploration_chain = {
            id = 'exploration_chain',
            name = 'Exploration Mastery Chain',
            description = 'Complete all exploration achievements',
            achievements = {
                'exploration_districts',
                'exploration_distance'
            },
            rewards = {
                { type = 'influence', amount = 1000 },
                { type = 'experience', amount = 2500 },
                { type = 'money', amount = 75000 },
                { type = 'special_title', value = 'Explorer' }
            }
        },
        
        teamwork_chain = {
            id = 'teamwork_chain',
            name = 'Teamwork Mastery Chain',
            description = 'Complete all teamwork achievements',
            achievements = {
                'teamwork_captures',
                'teamwork_missions'
            },
            rewards = {
                { type = 'influence', amount = 1000 },
                { type = 'experience', amount = 2500 },
                { type = 'money', amount = 75000 },
                { type = 'special_title', value = 'Team Player' }
            }
        }
    }
}

-- Achievement Creation Functions
local function CreateAchievementFromTemplate(templateId, customData)
    local template = AchievementSystem.achievementTemplates[templateId]
    if not template then
        return nil
    end
    
    local achievement = {
        id = template.id,
        name = template.name,
        description = template.description,
        category = template.category,
        type = template.type,
        icon = template.icon,
        color = template.color,
        requirements = template.requirements,
        rewards = template.rewards,
        milestones = template.milestones,
        maxProgress = template.maxProgress,
        customData = customData or {},
        createdTime = GetGameTimer()
    }
    
    return achievement
end

-- Player Progress Management
local function InitializePlayerProgress(playerId)
    if not AchievementSystem.playerProgress[playerId] then
        AchievementSystem.playerProgress[playerId] = {
            achievements = {},
            progress = {},
            completed = {},
            rewards = {},
            statistics = {
                total_achievements = 0,
                total_influence = 0,
                total_experience = 0,
                total_money = 0,
                categories_completed = {}
            }
        }
    end
end

local function GetPlayerProgress(playerId, achievementId)
    InitializePlayerProgress(playerId)
    return AchievementSystem.playerProgress[playerId].progress[achievementId] or 0
end

local function UpdatePlayerProgress(playerId, achievementId, progress)
    InitializePlayerProgress(playerId)
    
    local currentProgress = AchievementSystem.playerProgress[playerId].progress[achievementId] or 0
    local newProgress = math.min(currentProgress + progress, AchievementSystem.achievementTemplates[achievementId].maxProgress)
    
    AchievementSystem.playerProgress[playerId].progress[achievementId] = newProgress
    
    -- Check for milestone completion
    CheckAchievementMilestones(playerId, achievementId, newProgress)
    
    -- Check for achievement completion
    CheckAchievementCompletion(playerId, achievementId, newProgress)
    
    return newProgress
end

-- Achievement Completion Functions
local function CheckAchievementMilestones(playerId, achievementId, progress)
    local template = AchievementSystem.achievementTemplates[achievementId]
    if not template or not template.milestones then
        return
    end
    
    local playerData = AchievementSystem.playerProgress[playerId]
    local completedMilestones = playerData.achievements[achievementId] and playerData.achievements[achievementId].milestones or {}
    
    for _, milestone in ipairs(template.milestones) do
        if progress >= milestone.target and not completedMilestones[milestone.target] then
            -- Mark milestone as completed
            if not playerData.achievements[achievementId] then
                playerData.achievements[achievementId] = { milestones = {} }
            end
            playerData.achievements[achievementId].milestones[milestone.target] = true
            
            -- Award milestone reward
            AwardReward(playerId, milestone.reward)
            
            -- Trigger milestone event
            TriggerClientEvent('dz:achievement:milestone_completed', playerId, achievementId, milestone)
            
            print('^2[District Zero] ^7Player ' .. playerId .. ' completed milestone for achievement: ' .. achievementId)
        end
    end
end

local function CheckAchievementCompletion(playerId, achievementId, progress)
    local template = AchievementSystem.achievementTemplates[achievementId]
    if not template then
        return
    end
    
    local playerData = AchievementSystem.playerProgress[playerId]
    
    -- Check if already completed
    if playerData.completed[achievementId] then
        return
    end
    
    -- Check if all requirements are met
    local allRequirementsMet = true
    for _, requirement in ipairs(template.requirements) do
        if progress < requirement.target then
            allRequirementsMet = false
            break
        end
    end
    
    if allRequirementsMet then
        -- Mark achievement as completed
        playerData.completed[achievementId] = {
            completedTime = GetGameTimer(),
            progress = progress
        }
        
        -- Award achievement rewards
        for _, reward in ipairs(template.rewards) do
            AwardReward(playerId, reward)
        end
        
        -- Update statistics
        playerData.statistics.total_achievements = playerData.statistics.total_achievements + 1
        
        -- Check category completion
        CheckCategoryCompletion(playerId, template.category)
        
        -- Check chain completion
        CheckChainCompletion(playerId, achievementId)
        
        -- Trigger completion event
        TriggerClientEvent('dz:achievement:completed', playerId, achievementId, template)
        
        print('^2[District Zero] ^7Player ' .. playerId .. ' completed achievement: ' .. achievementId)
    end
end

local function CheckCategoryCompletion(playerId, category)
    local playerData = AchievementSystem.playerProgress[playerId]
    local categoryAchievements = {}
    
    -- Get all achievements in this category
    for achievementId, template in pairs(AchievementSystem.achievementTemplates) do
        if template.category == category then
            table.insert(categoryAchievements, achievementId)
        end
    end
    
    -- Check if all category achievements are completed
    local allCompleted = true
    for _, achievementId in ipairs(categoryAchievements) do
        if not playerData.completed[achievementId] then
            allCompleted = false
            break
        end
    end
    
    if allCompleted and not playerData.statistics.categories_completed[category] then
        playerData.statistics.categories_completed[category] = true
        
        -- Trigger category completion event
        TriggerClientEvent('dz:achievement:category_completed', playerId, category)
        
        print('^2[District Zero] ^7Player ' .. playerId .. ' completed category: ' .. category)
    end
end

local function CheckChainCompletion(playerId, achievementId)
    for chainId, chain in pairs(AchievementSystem.achievementChains) do
        -- Check if this achievement is part of a chain
        local isPartOfChain = false
        for _, chainAchievementId in ipairs(chain.achievements) do
            if chainAchievementId == achievementId then
                isPartOfChain = true
                break
            end
        end
        
        if isPartOfChain then
            local playerData = AchievementSystem.playerProgress[playerId]
            
            -- Check if all chain achievements are completed
            local allChainCompleted = true
            for _, chainAchievementId in ipairs(chain.achievements) do
                if not playerData.completed[chainAchievementId] then
                    allChainCompleted = false
                    break
                end
            end
            
            if allChainCompleted and not playerData.completed[chainId] then
                -- Mark chain as completed
                playerData.completed[chainId] = {
                    completedTime = GetGameTimer(),
                    type = 'chain'
                }
                
                -- Award chain rewards
                for _, reward in ipairs(chain.rewards) do
                    AwardReward(playerId, reward)
                end
                
                -- Trigger chain completion event
                TriggerClientEvent('dz:achievement:chain_completed', playerId, chainId, chain)
                
                print('^2[District Zero] ^7Player ' .. playerId .. ' completed chain: ' .. chainId)
            end
        end
    end
end

-- Reward System
local function AwardReward(playerId, reward)
    local playerData = AchievementSystem.playerProgress[playerId]
    
    if reward.type == 'influence' then
        playerData.statistics.total_influence = playerData.statistics.total_influence + reward.amount
        -- Trigger influence reward event
        TriggerClientEvent('dz:achievement:reward_influence', playerId, reward.amount)
        
    elseif reward.type == 'experience' then
        playerData.statistics.total_experience = playerData.statistics.total_experience + reward.amount
        -- Trigger experience reward event
        TriggerClientEvent('dz:achievement:reward_experience', playerId, reward.amount)
        
    elseif reward.type == 'money' then
        playerData.statistics.total_money = playerData.statistics.total_money + reward.amount
        -- Trigger money reward event
        TriggerClientEvent('dz:achievement:reward_money', playerId, reward.amount)
        
    elseif reward.type == 'special_title' then
        -- Trigger special title reward event
        TriggerClientEvent('dz:achievement:reward_title', playerId, reward.value)
    end
    
    -- Store reward
    if not playerData.rewards[reward.type] then
        playerData.rewards[reward.type] = 0
    end
    playerData.rewards[reward.type] = playerData.rewards[reward.type] + (reward.amount or 1)
end

-- Achievement System Methods
AchievementSystem.CreateAchievementFromTemplate = CreateAchievementFromTemplate
AchievementSystem.GetPlayerProgress = GetPlayerProgress
AchievementSystem.UpdatePlayerProgress = UpdatePlayerProgress
AchievementSystem.CheckAchievementMilestones = CheckAchievementMilestones
AchievementSystem.CheckAchievementCompletion = CheckAchievementCompletion
AchievementSystem.CheckCategoryCompletion = CheckCategoryCompletion
AchievementSystem.CheckChainCompletion = CheckChainCompletion
AchievementSystem.AwardReward = AwardReward

-- Exports
exports('CreateAchievementFromTemplate', CreateAchievementFromTemplate)
exports('GetPlayerProgress', GetPlayerProgress)
exports('UpdatePlayerProgress', UpdatePlayerProgress)
exports('CheckAchievementMilestones', CheckAchievementMilestones)
exports('CheckAchievementCompletion', CheckAchievementCompletion)
exports('CheckCategoryCompletion', CheckCategoryCompletion)
exports('CheckChainCompletion', CheckChainCompletion)
exports('AwardReward', AwardReward)

return AchievementSystem 