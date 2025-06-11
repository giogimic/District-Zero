Config.Districts = {
    {
        id = "downtown",
        name = "Downtown",
        center = vector3(0.0, 0.0, 0.0),
        radius = 500.0,
        controllingFaction = nil,
        eventHooks = {"raid", "emergency"},
        pvpEnabled = true,
        pveEnabled = true
    },
    {
        id = "industrial",
        name = "Industrial Zone",
        center = vector3(1000.0, -2000.0, 30.0),
        radius = 400.0,
        controllingFaction = nil,
        eventHooks = {"turf_war", "npc_gang_attack"},
        pvpEnabled = true,
        pveEnabled = true
    },
    {
        id = "residential",
        name = "Residential Area",
        center = vector3(-1500.0, 500.0, 40.0),
        radius = 350.0,
        controllingFaction = nil,
        eventHooks = {"emergency", "npc_patrol"},
        pvpEnabled = false,
        pveEnabled = true
    }
} 