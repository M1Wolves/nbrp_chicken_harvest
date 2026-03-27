local Chickens = {}

local function randomPointInRadius(center, radius)
    local angle = math.random() * math.pi * 2
    local dist = math.sqrt(math.random()) * radius

    local x = center.x + math.cos(angle) * dist
    local y = center.y + math.sin(angle) * dist
    local z = center.z + -0.75

    return vector3(x, y, z)
end

local function spawnChicken(zoneIndex)
    local zone = Config.SpawnZones[zoneIndex]
    if not zone then return end

    local coords = randomPointInRadius(zone.coords, zone.radius)

    local ped = CreatePed(28, Config.HenModel, coords.x, coords.y, coords.z, math.random(0, 359) + 0.0, true, true)
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        print('[nbrp_chicken_harvest] Failed to create chicken')
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(ped)
    if not netId or netId == 0 then
        print('[nbrp_chicken_harvest] Failed to get chicken netId')
        DeleteEntity(ped)
        return
    end

    Chickens[netId] = {
        entity = ped,
        zoneIndex = zoneIndex,
        busy = false
    }

    return netId
end

local function respawnChicken(zoneIndex)
    Wait(Config.RespawnSeconds * 1000)
    spawnChicken(zoneIndex)
end

CreateThread(function()
    Wait(2000)

    for zoneIndex, zone in ipairs(Config.SpawnZones) do
        for i = 1, zone.count do
            spawnChicken(zoneIndex)
            Wait(100)
        end
    end
end)

RegisterNetEvent('nbrp_chicken_harvest:tryCatch', function(netId)
    local src = source
    local chicken = Chickens[netId]

    if not chicken or chicken.busy then return end

    local ped = chicken.entity
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        Chickens[netId] = nil
        return
    end

    chicken.busy = true

    local playerPed = GetPlayerPed(src)
    if not playerPed or playerPed == 0 or not DoesEntityExist(playerPed) then
        chicken.busy = false
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    local chickenCoords = GetEntityCoords(ped)

    if #(playerCoords - chickenCoords) > 3.0 then
        chicken.busy = false
        return
    end

    local amount = math.random(Config.Reward.min, Config.Reward.max)
    local success = exports.ox_inventory:AddItem(src, Config.Reward.item, amount)

    if not success then
        chicken.busy = false
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chicken Harvest',
            description = 'Not enough inventory space.',
            type = 'error'
        })
        return
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Chicken Harvest',
        description = ('You received %s eggs.'):format(amount),
        type = 'success'
    })

    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end

    local respawnZone = chicken.zoneIndex
    Chickens[netId] = nil

    CreateThread(function()
        respawnChicken(respawnZone)
    end)
end)
