local QBCore = exports['qb-core']:GetCoreObject()

-- Dar recompensa al jugador
RegisterNetEvent('afkzone:giveReward', function(item, amount, label, timerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Verificar si el jugador tiene espacio en el inventario
    if item == "money" then
        Player.Functions.AddMoney('cash', amount)
        TriggerClientEvent('afkzone:receiveReward', src, item, amount, label, timerId)
        
        -- Log
        print(string.format("[AFK Zone] %s recibió $%d de dinero", GetPlayerName(src), amount))
    else
        -- Verificar si el item existe en QBCore
        if QBCore.Shared.Items[item] then
            -- Intentar agregar el item
            local success = Player.Functions.AddItem(item, amount)
            
            if success then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount)
                TriggerClientEvent('afkzone:receiveReward', src, item, amount, label, timerId)
                
                -- Log
                print(string.format("[AFK Zone] %s recibió %dx %s", GetPlayerName(src), amount, label))
            else
                TriggerClientEvent('QBCore:Notify', src, "No tienes espacio en el inventario", "error")
            end
        else
            print(string.format("[AFK Zone] ERROR: El item '%s' no existe en QBCore.Shared.Items", item))
            TriggerClientEvent('QBCore:Notify', src, "Error al recibir recompensa", "error")
        end
    end
end)

-- Comando para verificar estado AFK (admin)
QBCore.Commands.Add("checkafk", "Ver jugadores en la AFK Zone (Admin)", {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.name == "police" or Player.PlayerData.gang.name == "admin" then
        -- Aquí puedes implementar un sistema de tracking si lo deseas
        TriggerClientEvent('QBCore:Notify', src, "Comando en desarrollo", "primary")
    else
        TriggerClientEvent('QBCore:Notify', src, "No tienes permisos", "error")
    end
end, "admin")

-- Evento para logs avanzados (opcional - Discord webhook)
local function SendToDiscord(webhook, message, color)
    if not webhook or webhook == "" then return end
    
    local embeds = {
        {
            ["title"] = "AFK Zone System",
            ["description"] = message,
            ["color"] = color or 3066993,
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S"),
            },
        }
    }
    
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "AFK Zone Bot",
        embeds = embeds
    }), { ['Content-Type'] = 'application/json' })
end

-- Puedes descomentar esto y agregar tu webhook de Discord
--[[
RegisterNetEvent('afkzone:logReward', function(item, amount, label)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local message = string.format("**Jugador:** %s\n**Item:** %s\n**Cantidad:** %d", 
        GetPlayerName(src), label, amount)
    SendToDiscord("TU_WEBHOOK_AQUI", message, 3066993)
end)
]]