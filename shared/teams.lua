-- District Zero Advanced Team System
-- Version: 1.0.0

local AdvancedTeamSystem = {
    -- Team Roles
    teamRoles = {
        LEADER = 'leader',
        OFFICER = 'officer',
        VETERAN = 'veteran',
        MEMBER = 'member',
        RECRUIT = 'recruit'
    },
    
    -- Role Permissions
    rolePermissions = {
        leader = {
            invite = true,
            kick = true,
            promote = true,
            demote = true,
            disband = true,
            declare_war = true,
            form_alliance = true,
            manage_challenges = true,
            manage_funds = true,
            edit_team = true
        },
        officer = {
            invite = true,
            kick = true,
            promote = true,
            demote = true,
            declare_war = false,
            form_alliance = false,
            manage_challenges = true,
            manage_funds = false,
            edit_team = false
        },
        veteran = {
            invite = true,
            kick = false,
            promote = false,
            demote = false,
            declare_war = false,
            form_alliance = false,
            manage_challenges = false,
            manage_funds = false,
            edit_team = false
        },
        member = {
            invite = false,
            kick = false,
            promote = false,
            demote = false,
            declare_war = false,
            form_alliance = false,
            manage_challenges = false,
            manage_funds = false,
            edit_team = false
        },
        recruit = {
            invite = false,
            kick = false,
            promote = false,
            demote = false,
            declare_war = false,
            form_alliance = false,
            manage_challenges = false,
            manage_funds = false,
            edit_team = false
        }
    },
    
    -- Team States
    teamStates = {
        ACTIVE = 'active',
        INACTIVE = 'inactive',
        DISBANDED = 'disbanded',
        SUSPENDED = 'suspended'
    },
    
    -- War States
    warStates = {
        DECLARED = 'declared',
        ACTIVE = 'active',
        ENDED = 'ended',
        PEACE = 'peace'
    },
    
    -- Alliance States
    allianceStates = {
        PENDING = 'pending',
        ACTIVE = 'active',
        DISSOLVED = 'dissolved'
    },
    
    -- Challenge Types
    challengeTypes = {
        CAPTURE_CONTEST = 'capture_contest',
        MISSION_RACE = 'mission_race',
        ELIMINATION_BATTLE = 'elimination_battle',
        RESOURCE_WAR = 'resource_war',
        BOSS_HUNT = 'boss_hunt',
        ENDURANCE_TEST = 'endurance_test'
    },
    
    -- Active Teams
    activeTeams = {},
    
    -- Team Wars
    teamWars = {},
    
    -- Alliances
    alliances = {},
    
    -- Team Challenges
    teamChallenges = {},
    
    -- Team Statistics
    teamStats = {},
    
    -- Team Templates
    teamTemplates = {
        -- Standard Team Template
        standard = {
            name = "Team",
            description = "A standard team",
            maxMembers = 10,
            maxOfficers = 3,
            maxVeterans = 5,
            requirements = {
                minLevel = 1,
                minMembers = 1
            },
            permissions = {
                inviteOnly = false,
                autoAccept = true,
                requireApproval = false
            },
            progression = {
                experienceMultiplier = 1.0,
                influenceMultiplier = 1.0,
                rewardMultiplier = 1.0
            }
        },
        
        -- Elite Team Template
        elite = {
            name = "Elite Team",
            description = "An elite team with high standards",
            maxMembers = 8,
            maxOfficers = 2,
            maxVeterans = 4,
            requirements = {
                minLevel = 5,
                minMembers = 3
            },
            permissions = {
                inviteOnly = true,
                autoAccept = false,
                requireApproval = true
            },
            progression = {
                experienceMultiplier = 1.5,
                influenceMultiplier = 1.3,
                rewardMultiplier = 1.2
            }
        },
        
        -- Mercenary Team Template
        mercenary = {
            name = "Mercenary Team",
            description = "A mercenary team focused on combat",
            maxMembers = 12,
            maxOfficers = 4,
            maxVeterans = 6,
            requirements = {
                minLevel = 3,
                minMembers = 2
            },
            permissions = {
                inviteOnly = false,
                autoAccept = true,
                requireApproval = false
            },
            progression = {
                experienceMultiplier = 1.2,
                influenceMultiplier = 1.1,
                rewardMultiplier = 1.3
            }
        }
    },
    
    -- Challenge Templates
    challengeTemplates = {
        -- Capture Contest Challenge
        capture_contest = {
            name = "Capture Contest",
            description = "Teams compete to capture the most districts",
            type = 'capture_contest',
            duration = 3600000, -- 1 hour
            maxTeams = 4,
            requirements = {
                minTeamSize = 2,
                minTeamLevel = 1
            },
            objectives = {
                {
                    id = 'capture_districts',
                    type = 'capture',
                    name = 'Capture Districts',
                    description = 'Capture as many districts as possible',
                    targetCount = 5,
                    required = true,
                    rewards = {
                        influence = 200,
                        experience = 400
                    }
                }
            },
            rewards = {
                first = { influence = 1000, experience = 2000, money = 50000 },
                second = { influence = 500, experience = 1000, money = 25000 },
                third = { influence = 250, experience = 500, money = 12500 }
            }
        },
        
        -- Mission Race Challenge
        mission_race = {
            name = "Mission Race",
            description = "Teams race to complete missions first",
            type = 'mission_race',
            duration = 1800000, -- 30 minutes
            maxTeams = 6,
            requirements = {
                minTeamSize = 2,
                minTeamLevel = 2
            },
            objectives = {
                {
                    id = 'complete_missions',
                    type = 'mission',
                    name = 'Complete Missions',
                    description = 'Complete missions as quickly as possible',
                    targetCount = 10,
                    required = true,
                    rewards = {
                        influence = 150,
                        experience = 300
                    }
                }
            },
            rewards = {
                first = { influence = 800, experience = 1600, money = 40000 },
                second = { influence = 400, experience = 800, money = 20000 },
                third = { influence = 200, experience = 400, money = 10000 }
            }
        },
        
        -- Elimination Battle Challenge
        elimination_battle = {
            name = "Elimination Battle",
            description = "Teams battle in elimination matches",
            type = 'elimination_battle',
            duration = 1200000, -- 20 minutes
            maxTeams = 8,
            requirements = {
                minTeamSize = 3,
                minTeamLevel = 3
            },
            objectives = {
                {
                    id = 'eliminate_opponents',
                    type = 'elimination',
                    name = 'Eliminate Opponents',
                    description = 'Eliminate members of opposing teams',
                    targetCount = 20,
                    required = true,
                    rewards = {
                        influence = 300,
                        experience = 600
                    }
                }
            },
            rewards = {
                first = { influence = 1200, experience = 2400, money = 60000 },
                second = { influence = 600, experience = 1200, money = 30000 },
                third = { influence = 300, experience = 600, money = 15000 }
            }
        }
    }
}

-- Team Creation Functions
local function CreateTeamFromTemplate(template, leaderId, customData)
    local team = {
        id = 'team_' .. GetGameTimer(),
        name = template.name,
        description = template.description,
        template = template.name,
        leader = leaderId,
        officers = {},
        veterans = {},
        members = {},
        recruits = {},
        maxMembers = template.maxMembers,
        maxOfficers = template.maxOfficers,
        maxVeterans = template.maxVeterans,
        requirements = template.requirements,
        permissions = template.permissions,
        progression = template.progression,
        state = AdvancedTeamSystem.teamStates.ACTIVE,
        createdTime = GetGameTimer(),
        lastActivity = GetGameTimer(),
        stats = {
            captures = 0,
            missions = 0,
            influence = 0,
            experience = 0,
            wars_won = 0,
            wars_lost = 0,
            challenges_won = 0,
            challenges_lost = 0,
            total_members = 0,
            current_members = 0
        },
        funds = 0,
        level = 1,
        customData = customData or {}
    }
    
    -- Add leader as first member
    team.members[leaderId] = {
        id = leaderId,
        role = AdvancedTeamSystem.teamRoles.LEADER,
        joinTime = GetGameTimer(),
        lastActivity = GetGameTimer(),
        stats = {
            captures = 0,
            missions = 0,
            influence = 0,
            experience = 0
        }
    }
    
    team.stats.current_members = 1
    team.stats.total_members = 1
    
    return team
end

-- Team Management Functions
local function AddMemberToTeam(teamId, playerId, role)
    local team = AdvancedTeamSystem.activeTeams[teamId]
    if not team then
        return false, 'Team not found'
    end
    
    -- Check if team is full
    if team.stats.current_members >= team.maxMembers then
        return false, 'Team is full'
    end
    
    -- Check role limits
    if role == AdvancedTeamSystem.teamRoles.OFFICER then
        local officerCount = 0
        for _, member in pairs(team.members) do
            if member.role == AdvancedTeamSystem.teamRoles.OFFICER then
                officerCount = officerCount + 1
            end
        end
        if officerCount >= team.maxOfficers then
            return false, 'Maximum officers reached'
        end
    elseif role == AdvancedTeamSystem.teamRoles.VETERAN then
        local veteranCount = 0
        for _, member in pairs(team.members) do
            if member.role == AdvancedTeamSystem.teamRoles.VETERAN then
                veteranCount = veteranCount + 1
            end
        end
        if veteranCount >= team.maxVeterans then
            return false, 'Maximum veterans reached'
        end
    end
    
    -- Add member
    team.members[playerId] = {
        id = playerId,
        role = role or AdvancedTeamSystem.teamRoles.RECRUIT,
        joinTime = GetGameTimer(),
        lastActivity = GetGameTimer(),
        stats = {
            captures = 0,
            missions = 0,
            influence = 0,
            experience = 0
        }
    }
    
    team.stats.current_members = team.stats.current_members + 1
    team.stats.total_members = team.stats.total_members + 1
    team.lastActivity = GetGameTimer()
    
    return true, 'Member added'
end

local function RemoveMemberFromTeam(teamId, playerId)
    local team = AdvancedTeamSystem.activeTeams[teamId]
    if not team then
        return false, 'Team not found'
    end
    
    if not team.members[playerId] then
        return false, 'Member not found'
    end
    
    -- Remove member
    team.members[playerId] = nil
    team.stats.current_members = team.stats.current_members - 1
    team.lastActivity = GetGameTimer()
    
    -- Check if team should be disbanded
    if team.stats.current_members == 0 then
        team.state = AdvancedTeamSystem.teamStates.DISBANDED
    end
    
    return true, 'Member removed'
end

local function PromoteMember(teamId, playerId, newRole)
    local team = AdvancedTeamSystem.activeTeams[teamId]
    if not team then
        return false, 'Team not found'
    end
    
    if not team.members[playerId] then
        return false, 'Member not found'
    end
    
    local currentRole = team.members[playerId].role
    local roleHierarchy = {
        [AdvancedTeamSystem.teamRoles.RECRUIT] = 1,
        [AdvancedTeamSystem.teamRoles.MEMBER] = 2,
        [AdvancedTeamSystem.teamRoles.VETERAN] = 3,
        [AdvancedTeamSystem.teamRoles.OFFICER] = 4,
        [AdvancedTeamSystem.teamRoles.LEADER] = 5
    }
    
    if roleHierarchy[newRole] <= roleHierarchy[currentRole] then
        return false, 'Invalid promotion'
    end
    
    -- Check role limits
    if newRole == AdvancedTeamSystem.teamRoles.OFFICER then
        local officerCount = 0
        for _, member in pairs(team.members) do
            if member.role == AdvancedTeamSystem.teamRoles.OFFICER then
                officerCount = officerCount + 1
            end
        end
        if officerCount >= team.maxOfficers then
            return false, 'Maximum officers reached'
        end
    elseif newRole == AdvancedTeamSystem.teamRoles.VETERAN then
        local veteranCount = 0
        for _, member in pairs(team.members) do
            if member.role == AdvancedTeamSystem.teamRoles.VETERAN then
                veteranCount = veteranCount + 1
            end
        end
        if veteranCount >= team.maxVeterans then
            return false, 'Maximum veterans reached'
        end
    end
    
    -- Promote member
    team.members[playerId].role = newRole
    team.lastActivity = GetGameTimer()
    
    return true, 'Member promoted'
end

local function DemoteMember(teamId, playerId, newRole)
    local team = AdvancedTeamSystem.activeTeams[teamId]
    if not team then
        return false, 'Team not found'
    end
    
    if not team.members[playerId] then
        return false, 'Member not found'
    end
    
    local currentRole = team.members[playerId].role
    local roleHierarchy = {
        [AdvancedTeamSystem.teamRoles.RECRUIT] = 1,
        [AdvancedTeamSystem.teamRoles.MEMBER] = 2,
        [AdvancedTeamSystem.teamRoles.VETERAN] = 3,
        [AdvancedTeamSystem.teamRoles.OFFICER] = 4,
        [AdvancedTeamSystem.teamRoles.LEADER] = 5
    }
    
    if roleHierarchy[newRole] >= roleHierarchy[currentRole] then
        return false, 'Invalid demotion'
    end
    
    -- Demote member
    team.members[playerId].role = newRole
    team.lastActivity = GetGameTimer()
    
    return true, 'Member demoted'
end

-- Team War Functions
local function DeclareWar(teamId, targetTeamId, reason)
    local team = AdvancedTeamSystem.activeTeams[teamId]
    local targetTeam = AdvancedTeamSystem.activeTeams[targetTeamId]
    
    if not team or not targetTeam then
        return false, 'Team not found'
    end
    
    if team.state ~= AdvancedTeamSystem.teamStates.ACTIVE or targetTeam.state ~= AdvancedTeamSystem.teamStates.ACTIVE then
        return false, 'Team not active'
    end
    
    -- Check if war already exists
    for warId, war in pairs(AdvancedTeamSystem.teamWars) do
        if (war.attacker == teamId and war.defender == targetTeamId) or
           (war.attacker == targetTeamId and war.defender == teamId) then
            if war.state == AdvancedTeamSystem.warStates.ACTIVE or war.state == AdvancedTeamSystem.warStates.DECLARED then
                return false, 'War already in progress'
            end
        end
    end
    
    -- Create war
    local war = {
        id = 'war_' .. GetGameTimer(),
        attacker = teamId,
        defender = targetTeamId,
        reason = reason or 'No reason given',
        state = AdvancedTeamSystem.warStates.DECLARED,
        declaredTime = GetGameTimer(),
        startTime = 0,
        endTime = 0,
        duration = 3600000, -- 1 hour
        stats = {
            attacker_score = 0,
            defender_score = 0,
            attacker_captures = 0,
            defender_captures = 0,
            attacker_eliminations = 0,
            defender_eliminations = 0
        },
        winner = nil
    }
    
    AdvancedTeamSystem.teamWars[war.id] = war
    
    return true, 'War declared', war.id
end

local function StartWar(warId)
    local war = AdvancedTeamSystem.teamWars[warId]
    if not war then
        return false, 'War not found'
    end
    
    if war.state ~= AdvancedTeamSystem.warStates.DECLARED then
        return false, 'War not in declared state'
    end
    
    war.state = AdvancedTeamSystem.warStates.ACTIVE
    war.startTime = GetGameTimer()
    war.endTime = war.startTime + war.duration
    
    return true, 'War started'
end

local function EndWar(warId, winner)
    local war = AdvancedTeamSystem.teamWars[warId]
    if not war then
        return false, 'War not found'
    end
    
    war.state = AdvancedTeamSystem.warStates.ENDED
    war.endTime = GetGameTimer()
    war.winner = winner
    
    -- Update team stats
    if winner == war.attacker then
        local attackerTeam = AdvancedTeamSystem.activeTeams[war.attacker]
        if attackerTeam then
            attackerTeam.stats.wars_won = attackerTeam.stats.wars_won + 1
        end
        
        local defenderTeam = AdvancedTeamSystem.activeTeams[war.defender]
        if defenderTeam then
            defenderTeam.stats.wars_lost = defenderTeam.stats.wars_lost + 1
        end
    elseif winner == war.defender then
        local defenderTeam = AdvancedTeamSystem.activeTeams[war.defender]
        if defenderTeam then
            defenderTeam.stats.wars_won = defenderTeam.stats.wars_won + 1
        end
        
        local attackerTeam = AdvancedTeamSystem.activeTeams[war.attacker]
        if attackerTeam then
            attackerTeam.stats.wars_lost = attackerTeam.stats.wars_lost + 1
        end
    end
    
    return true, 'War ended'
end

-- Alliance Functions
local function ProposeAlliance(teamId, targetTeamId, terms)
    local team = AdvancedTeamSystem.activeTeams[teamId]
    local targetTeam = AdvancedTeamSystem.activeTeams[targetTeamId]
    
    if not team or not targetTeam then
        return false, 'Team not found'
    end
    
    if team.state ~= AdvancedTeamSystem.teamStates.ACTIVE or targetTeam.state ~= AdvancedTeamSystem.teamStates.ACTIVE then
        return false, 'Team not active'
    end
    
    -- Check if alliance already exists
    for allianceId, alliance in pairs(AdvancedTeamSystem.alliances) do
        if (alliance.team1 == teamId and alliance.team2 == targetTeamId) or
           (alliance.team1 == targetTeamId and alliance.team2 == teamId) then
            if alliance.state == AdvancedTeamSystem.allianceStates.ACTIVE or alliance.state == AdvancedTeamSystem.allianceStates.PENDING then
                return false, 'Alliance already exists'
            end
        end
    end
    
    -- Create alliance proposal
    local alliance = {
        id = 'alliance_' .. GetGameTimer(),
        team1 = teamId,
        team2 = targetTeamId,
        proposer = teamId,
        terms = terms or {},
        state = AdvancedTeamSystem.allianceStates.PENDING,
        proposedTime = GetGameTimer(),
        acceptedTime = 0,
        dissolvedTime = 0
    }
    
    AdvancedTeamSystem.alliances[alliance.id] = alliance
    
    return true, 'Alliance proposed', alliance.id
end

local function AcceptAlliance(allianceId)
    local alliance = AdvancedTeamSystem.alliances[allianceId]
    if not alliance then
        return false, 'Alliance not found'
    end
    
    if alliance.state ~= AdvancedTeamSystem.allianceStates.PENDING then
        return false, 'Alliance not pending'
    end
    
    alliance.state = AdvancedTeamSystem.allianceStates.ACTIVE
    alliance.acceptedTime = GetGameTimer()
    
    return true, 'Alliance accepted'
end

local function DissolveAlliance(allianceId)
    local alliance = AdvancedTeamSystem.alliances[allianceId]
    if not alliance then
        return false, 'Alliance not found'
    end
    
    alliance.state = AdvancedTeamSystem.allianceStates.DISSOLVED
    alliance.dissolvedTime = GetGameTimer()
    
    return true, 'Alliance dissolved'
end

-- Team Challenge Functions
local function CreateTeamChallenge(template, teams, customData)
    local challenge = {
        id = 'challenge_' .. GetGameTimer(),
        name = template.name,
        description = template.description,
        type = template.type,
        template = template.name,
        teams = teams,
        state = 'pending',
        startTime = 0,
        endTime = 0,
        duration = template.duration,
        requirements = template.requirements,
        objectives = {},
        rewards = template.rewards,
        participants = {},
        progress = {},
        results = {},
        customData = customData or {}
    }
    
    -- Copy and customize objectives
    for _, objective in ipairs(template.objectives) do
        local newObjective = {}
        for key, value in pairs(objective) do
            newObjective[key] = value
        end
        newObjective.id = objective.id .. '_' .. challenge.id
        newObjective.completed = false
        newObjective.progress = 0
        table.insert(challenge.objectives, newObjective)
    end
    
    -- Initialize team progress
    for _, teamId in ipairs(teams) do
        challenge.participants[teamId] = {
            joinTime = GetGameTimer(),
            progress = {},
            score = 0
        }
    end
    
    return challenge
end

local function StartTeamChallenge(challengeId)
    local challenge = AdvancedTeamSystem.teamChallenges[challengeId]
    if not challenge then
        return false, 'Challenge not found'
    end
    
    challenge.state = 'active'
    challenge.startTime = GetGameTimer()
    challenge.endTime = challenge.startTime + challenge.duration
    
    -- Initialize objectives
    for _, objective in ipairs(challenge.objectives) do
        objective.completed = false
        objective.progress = 0
        objective.startTime = GetGameTimer()
    end
    
    return true, 'Challenge started'
end

local function UpdateChallengeProgress(challengeId, teamId, objectiveId, progress)
    local challenge = AdvancedTeamSystem.teamChallenges[challengeId]
    if not challenge or challenge.state ~= 'active' then
        return false, 'Challenge not active'
    end
    
    if not challenge.participants[teamId] then
        return false, 'Team not participating'
    end
    
    -- Find objective
    local objective = nil
    for _, obj in ipairs(challenge.objectives) do
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
    if objective.type == 'capture' then
        if progress >= objective.targetCount then
            objective.completed = true
        end
    elseif objective.type == 'mission' then
        if progress >= objective.targetCount then
            objective.completed = true
        end
    elseif objective.type == 'elimination' then
        if progress >= objective.targetCount then
            objective.completed = true
        end
    end
    
    -- Update team progress
    challenge.participants[teamId].progress[objectiveId] = progress
    
    -- Calculate team score
    local score = 0
    for _, obj in ipairs(challenge.objectives) do
        if obj.completed then
            score = score + (obj.rewards.influence or 0)
        end
    end
    challenge.participants[teamId].score = score
    
    return true, 'Progress updated'
end

local function EndTeamChallenge(challengeId)
    local challenge = AdvancedTeamSystem.teamChallenges[challengeId]
    if not challenge then
        return false, 'Challenge not found'
    end
    
    challenge.state = 'completed'
    challenge.endTime = GetGameTimer()
    
    -- Calculate results
    local teams = {}
    for teamId, participant in pairs(challenge.participants) do
        table.insert(teams, { id = teamId, score = participant.score })
    end
    
    table.sort(teams, function(a, b) return a.score > b.score end)
    
    challenge.results = teams
    
    -- Distribute rewards
    if #teams >= 1 and challenge.rewards.first then
        local team1 = AdvancedTeamSystem.activeTeams[teams[1].id]
        if team1 then
            team1.stats.challenges_won = team1.stats.challenges_won + 1
            team1.funds = team1.funds + (challenge.rewards.first.money or 0)
        end
    end
    
    if #teams >= 2 and challenge.rewards.second then
        local team2 = AdvancedTeamSystem.activeTeams[teams[2].id]
        if team2 then
            team2.funds = team2.funds + (challenge.rewards.second.money or 0)
        end
    end
    
    if #teams >= 3 and challenge.rewards.third then
        local team3 = AdvancedTeamSystem.activeTeams[teams[3].id]
        if team3 then
            team3.funds = team3.funds + (challenge.rewards.third.money or 0)
        end
    end
    
    return true, 'Challenge ended'
end

-- Team Progression Functions
local function CalculateTeamLevel(team)
    local totalExperience = team.stats.experience
    local level = math.floor(totalExperience / 10000) + 1
    return level
end

local function UpdateTeamProgression(teamId)
    local team = AdvancedTeamSystem.activeTeams[teamId]
    if not team then
        return false, 'Team not found'
    end
    
    -- Calculate new level
    local newLevel = CalculateTeamLevel(team)
    if newLevel > team.level then
        team.level = newLevel
        
        -- Level up rewards
        team.funds = team.funds + (newLevel * 1000)
        
        return true, 'Team leveled up to ' .. newLevel
    end
    
    return false, 'No level up'
end

-- Advanced Team System Methods
AdvancedTeamSystem.CreateTeamFromTemplate = CreateTeamFromTemplate
AdvancedTeamSystem.AddMemberToTeam = AddMemberToTeam
AdvancedTeamSystem.RemoveMemberFromTeam = RemoveMemberFromTeam
AdvancedTeamSystem.PromoteMember = PromoteMember
AdvancedTeamSystem.DemoteMember = DemoteMember
AdvancedTeamSystem.DeclareWar = DeclareWar
AdvancedTeamSystem.StartWar = StartWar
AdvancedTeamSystem.EndWar = EndWar
AdvancedTeamSystem.ProposeAlliance = ProposeAlliance
AdvancedTeamSystem.AcceptAlliance = AcceptAlliance
AdvancedTeamSystem.DissolveAlliance = DissolveAlliance
AdvancedTeamSystem.CreateTeamChallenge = CreateTeamChallenge
AdvancedTeamSystem.StartTeamChallenge = StartTeamChallenge
AdvancedTeamSystem.UpdateChallengeProgress = UpdateChallengeProgress
AdvancedTeamSystem.EndTeamChallenge = EndTeamChallenge
AdvancedTeamSystem.UpdateTeamProgression = UpdateTeamProgression

-- Cleanup Thread
CreateThread(function()
    while true do
        Wait(60000) -- Every minute
        
        -- Update team progression
        for teamId, team in pairs(AdvancedTeamSystem.activeTeams) do
            UpdateTeamProgression(teamId)
        end
        
        -- Clean up expired wars
        local currentTime = GetGameTimer()
        for warId, war in pairs(AdvancedTeamSystem.teamWars) do
            if war.state == AdvancedTeamSystem.warStates.ACTIVE and war.endTime < currentTime then
                EndWar(warId, nil) -- Draw
            end
        end
        
        -- Clean up expired challenges
        for challengeId, challenge in pairs(AdvancedTeamSystem.teamChallenges) do
            if challenge.state == 'active' and challenge.endTime < currentTime then
                EndTeamChallenge(challengeId)
            end
        end
    end
end)

-- Exports
exports('CreateTeamFromTemplate', CreateTeamFromTemplate)
exports('AddMemberToTeam', AddMemberToTeam)
exports('RemoveMemberFromTeam', RemoveMemberFromTeam)
exports('PromoteMember', PromoteMember)
exports('DemoteMember', DemoteMember)
exports('DeclareWar', DeclareWar)
exports('StartWar', StartWar)
exports('EndWar', EndWar)
exports('ProposeAlliance', ProposeAlliance)
exports('AcceptAlliance', AcceptAlliance)
exports('DissolveAlliance', DissolveAlliance)
exports('CreateTeamChallenge', CreateTeamChallenge)
exports('StartTeamChallenge', StartTeamChallenge)
exports('UpdateChallengeProgress', UpdateChallengeProgress)
exports('EndTeamChallenge', EndTeamChallenge)
exports('UpdateTeamProgression', UpdateTeamProgression)

return AdvancedTeamSystem 