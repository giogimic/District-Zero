-- District Zero Districts Configuration
-- Version: 1.0.0

Config = Config or {}
Config.Districts = {
    downtown = {
        name = "Downtown District",
        description = "The heart of the city with high-rise buildings and corporate offices",
        coords = vector3(-200.0, -1000.0, 30.0),
        radius = 500.0,
        color = 1,
        controlPoints = {
            {
                id = "city_hall",
                name = "City Hall",
                coords = vector3(-200.0, -1000.0, 30.0),
                radius = 50.0,
                influence = 25
            },
            {
                id = "financial_district",
                name = "Financial District",
                coords = vector3(-150.0, -950.0, 30.0),
                radius = 40.0,
                influence = 20
            },
            {
                id = "shopping_center",
                name = "Shopping Center",
                coords = vector3(-250.0, -1050.0, 30.0),
                radius = 45.0,
                influence = 15
            },
            {
                id = "metro_station",
                name = "Metro Station",
                coords = vector3(-180.0, -1020.0, 30.0),
                radius = 35.0,
                influence = 10
            }
        }
    },
    
    industrial = {
        name = "Industrial District",
        description = "Factories, warehouses, and manufacturing facilities",
        coords = vector3(800.0, -2000.0, 30.0),
        radius = 600.0,
        color = 2,
        controlPoints = {
            {
                id = "factory_main",
                name = "Main Factory",
                coords = vector3(800.0, -2000.0, 30.0),
                radius = 60.0,
                influence = 30
            },
            {
                id = "warehouse_complex",
                name = "Warehouse Complex",
                coords = vector3(850.0, -1950.0, 30.0),
                radius = 50.0,
                influence = 20
            },
            {
                id = "shipping_dock",
                name = "Shipping Dock",
                coords = vector3(750.0, -2050.0, 30.0),
                radius = 40.0,
                influence = 15
            },
            {
                id = "power_plant",
                name = "Power Plant",
                coords = vector3(900.0, -2100.0, 30.0),
                radius = 55.0,
                influence = 25
            }
        }
    },
    
    residential = {
        name = "Residential District",
        description = "Housing areas with apartments and family homes",
        coords = vector3(-500.0, 500.0, 30.0),
        radius = 400.0,
        color = 3,
        controlPoints = {
            {
                id = "apartment_complex",
                name = "Apartment Complex",
                coords = vector3(-500.0, 500.0, 30.0),
                radius = 45.0,
                influence = 20
            },
            {
                id = "park_recreation",
                name = "Park & Recreation",
                coords = vector3(-450.0, 550.0, 30.0),
                radius = 40.0,
                influence = 15
            },
            {
                id = "school_zone",
                name = "School Zone",
                coords = vector3(-550.0, 450.0, 30.0),
                radius = 35.0,
                influence = 10
            },
            {
                id = "community_center",
                name = "Community Center",
                coords = vector3(-480.0, 480.0, 30.0),
                radius = 30.0,
                influence = 10
            }
        }
    },
    
    entertainment = {
        name = "Entertainment District",
        description = "Nightlife, casinos, and entertainment venues",
        coords = vector3(1200.0, 300.0, 30.0),
        radius = 450.0,
        color = 4,
        controlPoints = {
            {
                id = "casino_main",
                name = "Main Casino",
                coords = vector3(1200.0, 300.0, 30.0),
                radius = 55.0,
                influence = 25
            },
            {
                id = "nightclub_district",
                name = "Nightclub District",
                coords = vector3(1250.0, 350.0, 30.0),
                radius = 45.0,
                influence = 20
            },
            {
                id = "theater_complex",
                name = "Theater Complex",
                coords = vector3(1150.0, 250.0, 30.0),
                radius = 40.0,
                influence = 15
            },
            {
                id = "shopping_mall",
                name = "Shopping Mall",
                coords = vector3(1300.0, 200.0, 30.0),
                radius = 50.0,
                influence = 20
            }
        }
    },
    
    waterfront = {
        name = "Waterfront District",
        description = "Marina, beaches, and coastal attractions",
        coords = vector3(-1000.0, -1500.0, 30.0),
        radius = 550.0,
        color = 5,
        controlPoints = {
            {
                id = "marina_harbor",
                name = "Marina Harbor",
                coords = vector3(-1000.0, -1500.0, 30.0),
                radius = 60.0,
                influence = 25
            },
            {
                id = "beach_front",
                name = "Beach Front",
                coords = vector3(-950.0, -1450.0, 30.0),
                radius = 50.0,
                influence = 20
            },
            {
                id = "fishing_pier",
                name = "Fishing Pier",
                coords = vector3(-1050.0, -1550.0, 30.0),
                radius = 40.0,
                influence = 15
            },
            {
                id = "coastal_park",
                name = "Coastal Park",
                coords = vector3(-1100.0, -1400.0, 30.0),
                radius = 45.0,
                influence = 15
            }
        }
    }
} 