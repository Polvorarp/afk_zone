Config = {}

-- Configuración de la zona AFK
Config.AFKZone = {
    coords = vector3(-269.4, -957.3, 31.2), -- Coordenadas del centro (Legion Square ejemplo)
    radius = 15.0, -- Radio de la zona en metros
    blip = {
        enabled = true,
        sprite = 280,
        color = 47,
        scale = 0.8,
        label = "AFK Zone"
    }
}

-- Items que se pueden obtener con su tiempo individual (en milisegundos)
Config.RewardItems = {
    {item = "water", label = "Agua", min = 1, max = 2, time = 180000}, -- 3 minutos
    {item = "bread", label = "Pan", min = 1, max = 2, time = 180000}, -- 3 minutos
    {item = "sandwich", label = "Sandwich", min = 1, max = 1, time = 300000}, -- 5 minutos
    {item = "bandage", label = "Vendaje", min = 1, max = 1, time = 420000}, -- 7 minutos
    {item = "lockpick", label = "Ganzúa", min = 1, max = 1, time = 600000}, -- 10 minutos
    {item = "phone", label = "Teléfono", min = 1, max = 1, time = 900000}, -- 15 minutos
    {item = "weapon_pistol", label = "Pistola", min = 1, max = 1, time = 1800000}, -- 30 minutos
    {item = "money", label = "Dinero", min = 100, max = 500, time = 600000}, -- 10 minutos
}

-- Configuración de necesidades
Config.FreezeNeeds = {
    enabled = true, -- Activar/desactivar el congelamiento de necesidades
    hunger = true,  -- Congelar hambre
    thirst = true   -- Congelar sed
}

-- Bonus items (items adicionales que se muestran en la UI)
Config.BonusItems = {
    {item = "water", label = "Agua"},
    {item = "bread", label = "Pan"}
}

-- Framework QBCore
Config.Framework = "qb"

-- Comandos
Config.Commands = {
    teleport = "afkzone" -- Comando para teleportarse a la zona (solo admin)
}