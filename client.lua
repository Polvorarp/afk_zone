local QBCore = exports['qb-core']:GetCoreObject()
local isInAFKZone = false
local afkTime = 0
local rewardTimers = {} -- Timer individual para cada item
local rewardCount = 0
local originalHunger = nil
local originalThirst = nil

-- Inicializar timers para cada item
local function InitializeTimers()
    rewardTimers = {}
    for i, item in ipairs(Config.RewardItems) do
        rewardTimers[i] = {
            item = item.item,
            label = item.label,
            min = item.min,
            max = item.max,
            time = item.time,
            currentTime = 0,
            enabled = true
        }
    end
end

-- Crear blip
Citizen.CreateThread(function()
    if Config.AFKZone.blip.enabled then
        local blip = AddBlipForCoord(Config.AFKZone.coords.x, Config.AFKZone.coords.y, Config.AFKZone.coords.z)
        SetBlipSprite(blip, Config.AFKZone.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.AFKZone.blip.scale)
        SetBlipColour(blip, Config.AFKZone.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.AFKZone.blip.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Crear la zona con PolyZone
Citizen.CreateThread(function()
    local afkZone = CircleZone:Create(Config.AFKZone.coords, Config.AFKZone.radius, {
        name = "afk_zone",
        debugPoly = false
    })

    afkZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            EnterAFKZone()
        else
            LeaveAFKZone()
        end
    end)
end)

-- Función al entrar a la zona
function EnterAFKZone()
    isInAFKZone = true
    afkTime = 0
    rewardCount = 0
    
    -- Inicializar timers
    InitializeTimers()
    
    -- Guardar valores originales de hambre y sed
    if Config.FreezeNeeds.enabled then
        TriggerEvent('hud:client:UpdateNeeds', function(hunger, thirst)
            originalHunger = hunger
            originalThirst = thirst
        end)
    end
    
    -- Enviar todos los timers a la UI
    local timersData = {}
    for i, timer in ipairs(rewardTimers) do
        table.insert(timersData, {
            id = i,
            label = timer.label,
            item = timer.item,
            time = timer.time,
            currentTime = 0
        })
    end
    
    -- Mostrar UI
    SendNUIMessage({
        action = "showUI",
        data = {
            time = 0,
            rewards = 0,
            bonusItems = Config.BonusItems,
            timers = timersData
        }
    })
    
    -- Notificación
    QBCore.Functions.Notify("Has entrado a la AFK Zone. Tus necesidades no disminuirán aquí", "success", 5000)
end

-- Función al salir de la zona
function LeaveAFKZone()
    isInAFKZone = false
    afkTime = 0
    rewardTimers = {}
    
    -- Ocultar UI
    SendNUIMessage({
        action = "hideUI"
    })
    
    -- Notificación
    QBCore.Functions.Notify("Has salido de la AFK Zone", "primary", 3000)
end

-- Loop principal
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        
        if isInAFKZone then
            sleep = 1000
            afkTime = afkTime + 1
            
            -- Actualizar cada timer individual
            for i, timer in ipairs(rewardTimers) do
                if timer.enabled then
                    timer.currentTime = timer.currentTime + 1000
                    
                    -- Si el timer alcanza el tiempo necesario, dar recompensa
                    if timer.currentTime >= timer.time then
                        local amount = math.random(timer.min, timer.max)
                        TriggerServerEvent('afkzone:giveReward', timer.item, amount, timer.label, i)
                        rewardCount = rewardCount + 1
                        
                        -- Reiniciar el timer
                        timer.currentTime = 0
                    end
                    
                    -- Enviar actualización del timer a la UI
                    SendNUIMessage({
                        action = "updateTimer",
                        id = i,
                        currentTime = timer.currentTime,
                        totalTime = timer.time,
                        timeRemaining = math.floor((timer.time - timer.currentTime) / 1000)
                    })
                end
            end
            
            -- Actualizar tiempo total y contador de recompensas
            SendNUIMessage({
                action = "updateTime",
                time = afkTime,
                rewards = rewardCount
            })
            
            -- Congelar necesidades (QBCore)
            if Config.FreezeNeeds.enabled then
                if Config.FreezeNeeds.hunger and originalHunger then
                    TriggerEvent('hud:client:UpdateNeeds', originalHunger, originalThirst)
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)

-- Recibir recompensa del servidor
RegisterNetEvent('afkzone:receiveReward', function(item, amount, label, timerId)
    -- Actualizar UI con nueva recompensa
    SendNUIMessage({
        action = "newReward",
        item = item,
        label = label,
        amount = amount,
        timerId = timerId
    })
    
    -- Notificación
    QBCore.Functions.Notify("Recompensa AFK: " .. amount .. "x " .. label, "success", 3000)
end)

-- Comando de teleport (solo admin)
RegisterCommand(Config.Commands.teleport, function()
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, Config.AFKZone.coords.x, Config.AFKZone.coords.y, Config.AFKZone.coords.z)
    QBCore.Functions.Notify("Teleportado a la AFK Zone", "success")
end, false)

-- Dibujar marcador en la zona
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.AFKZone.coords)
        
        if distance < 50.0 then
            sleep = 0
            DrawMarker(1, Config.AFKZone.coords.x, Config.AFKZone.coords.y, Config.AFKZone.coords.z - 1.0, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                Config.AFKZone.radius * 2, Config.AFKZone.radius * 2, 1.0, 
                52, 235, 189, 50, 
                false, true, 2, false, nil, nil, false)
        end
        
        Citizen.Wait(sleep)
    end
end)