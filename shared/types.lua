-- Shared Types for District Zero
-- Version: 1.0.0

-- District types
---@class District
---@field id string
---@field name string
---@field description string
---@field owner string
---@field influence number
---@field blip DistrictBlip
---@field zones DistrictZone[]
---@field controlPoints ControlPoint[]

---@class DistrictBlip
---@field sprite number
---@field color number
---@field scale number
---@field coords vector3

---@class DistrictZone
---@field name string
---@field coords vector3
---@field radius number
---@field isSafeZone boolean

---@class ControlPoint
---@field name string
---@field coords vector3
---@field radius number
---@field influence number

-- Mission types
---@class Mission
---@field id string
---@field title string
---@field description string
---@field difficulty string
---@field reward number
---@field district string
---@field requirements {level: number, items: table}
---@field objectives MissionObjective[]

---@class MissionObjective
---@field type 'capture'|'eliminate'
---@field target string
---@field count number
---@field timeLimit number
---@field completed boolean

-- Team types (Simple PvP/PvE system)
---@class Team
---@field id string
---@field name string
---@field description string
---@field color string
---@field blip TeamBlip

---@class TeamBlip
---@field sprite number
---@field color number
---@field scale number

-- Event types
---@class UIData
---@field missions Mission[]
---@field districts District[]
---@field currentDistrict District
---@field currentTeam string

-- Database types
---@class DistrictData
---@field id string
---@field name string
---@field description string
---@field influence_pvp number
---@field influence_pve number
---@field last_updated string

---@class ControlPointData
---@field id number
---@field district_id string
---@field name string
---@field coords_x number
---@field coords_y number
---@field coords_z number
---@field radius number
---@field influence number
---@field current_team string
---@field last_captured string

---@class MissionData
---@field id string
---@field title string
---@field description string
---@field type string
---@field district_id string
---@field reward number
---@field objectives string
---@field active boolean

---@class MissionProgressData
---@field id number
---@field mission_id string
---@field citizenid string
---@field status string
---@field started_at string
---@field completed_at string
---@field objectives_completed string

---@class PlayerTeamData
---@field citizenid string
---@field team string
---@field last_updated string

Types = {
    District = {
        id = 'string',
        name = 'string',
        description = 'string',
        owner = 'string',
        influence = 'number',
        blip = {
            sprite = 'number',
            color = 'number',
            scale = 'number',
            coords = 'vector3'
        },
        zones = {
            {
                name = 'string',
                coords = 'vector3',
                radius = 'number'
            }
        }
    },

    Mission = {
        id = 'string',
        title = 'string',
        description = 'string',
        difficulty = 'string',
        reward = 'number',
        district = 'string',
        requirements = {
            level = 'number',
            items = 'table'
        }
    },

    Team = {
        id = 'string',
        name = 'string',
        description = 'string',
        color = 'string',
        blip = {
            sprite = 'number',
            color = 'number',
            scale = 'number'
        }
    },

    Player = {
        citizenid = 'string',
        team = 'string',
        district = 'string',
        missions = 'table',
        abilities = 'table'
    }
}

return Types 