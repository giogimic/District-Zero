-- Shared Types for District Zero
-- Version: 1.0.0

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

    Faction = {
        id = 'string',
        name = 'string',
        description = 'string',
        color = 'string',
        ranks = {
            {
                id = 'number',
                name = 'string',
                salary = 'number'
            }
        }
    },

    Player = {
        citizenid = 'string',
        faction = 'string',
        district = 'string',
        missions = 'table',
        abilities = 'table'
    }
}

return Types 