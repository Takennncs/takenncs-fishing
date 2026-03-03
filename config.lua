Config = {}

Config.FishingRod = 'fishingrod'

Config.Language = 'ee'

Config.ProgressBar = {
    prepareTime = 3000,
}

Config.CatchTime = {
    min = 4000,
    max = 10000
}

Config.MaxDistance = 2.0
Config.LocationCooldown = 300

Config.Skillbar = {
    enabled = true,
    speed = 20 
}

Config.Locations = {
    [1] = {
        name = "Vespucci Beach",
        coords = vec3(-1500.5, -1400.3, 2.5),
        radius = 3.0,
        maxFishing = 5,
        fished = 0,
        cooldown = 0
    },
    [2] = {
        name = "Alamo Sea",
        coords = vec3(368.9884, 3639.4155, 31.4190),
        radius = 3.5,
        maxFishing = 6,
        fished = 0,
        cooldown = 0
    },
    [3] = {
        name = "Paleto Bay",
        coords = vec3(-180.0, 6200.0, 31.0),
        radius = 3.0,
        maxFishing = 4,
        fished = 0,
        cooldown = 0
    }
}

Config.Fish = {
    ["fishingbass"] = {
        label = "Ahven",
        price = 35,
        chance = 20,
        image = "fishingbass.png"
    },
    ["fishingcod"] = {
        label = "Tursk",
        price = 45,
        chance = 18,
        image = "fishingcod.png"
    },
    ["fishingmackerel"] = {
        label = "Makrell",
        price = 30,
        chance = 15,
        image = "fishingmackerel.png"
    },
    ["fishingbluefish"] = {
        label = "Sinikala",
        price = 40,
        chance = 15,
        image = "fishingbluefish.png"
    },
    ["fishingflounder"] = {
        label = "Harilik polaarlest",
        price = 50,
        chance = 12,
        image = "fishingflounder.png"
    },
    ["fishingshark"] = {
        label = "Väikene haikala",
        price = 100,
        chance = 8,
        image = "fishingshark.png"
    },
    ["fishingdolphin"] = {
        label = "Väikene delfiin",
        price = 120,
        chance = 7,
        image = "fishingdolphin.png"
    },
    ["fishingwhale"] = {
        label = "Väikene vaal",
        price = 150,
        chance = 5,
        image = "fishingwhale.png"
    }
}

Config.Seller = {
    model = 'a_m_m_farmer_01',
    coords = vec3(-1504.1454, -1400.8398, 1.5206),
    heading = 90.0
}