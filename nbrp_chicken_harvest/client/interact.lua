local function loadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000

    while not HasAnimDictLoaded(dict) do
        Wait(50)
        if GetGameTimer() > timeout then
            return false
        end
    end

    return true
end

local function getClosestChicken()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPed = nil
    local closestDist = Config.InteractDistance

    local handle, ped = FindFirstPed()
    local success

    repeat
        if DoesEntityExist(ped)
            and not IsPedAPlayer(ped)
            and GetEntityModel(ped) == Config.HenModel
        then
            local dist = #(playerCoords - GetEntityCoords(ped))
            if dist <= closestDist then
                closestDist = dist
                closestPed = ped
            end
        end

        success, ped = FindNextPed(handle)
    until not success

    EndFindPed(handle)

    return closestPed
end

local function playCatchAnim(chicken)
    local playerPed = PlayerPedId()
    local chickenCoords = GetEntityCoords(chicken)

    TaskTurnPedToFaceCoord(playerPed, chickenCoords.x, chickenCoords.y, chickenCoords.z, 250)
    Wait(250)

    TaskGoStraightToCoord(playerPed, chickenCoords.x, chickenCoords.y, chickenCoords.z, 2.0, 1000, 0.0, 0.0)
    Wait(700)

    local dict = 'amb@prop_human_bum_bin@idle_b'
    local anim = 'idle_d'

    if loadAnimDict(dict) then
        TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, 1200, 0, 0.0, false, false, false)
    end
end

CreateThread(function()
    while true do
        local sleep = 1000

        if not ChickenHarvest.Busy then
            local chicken = getClosestChicken()

            if chicken and NetworkGetEntityIsNetworked(chicken) then
                sleep = 0
                ChickenHarvest.ShowText()

                if IsControlJustPressed(0, 38) then
                    ChickenHarvest.Busy = true
                    ChickenHarvest.HideText()

                    playCatchAnim(chicken)

                    local success = lib.progressBar({
                        duration = Config.CatchDuration,
                        label = 'Catching chicken...',
                        useWhileDead = false,
                        canCancel = false,
                        disable = {
                            move = true,
                            car = true,
                            combat = true
                        }
                    })

                    if success and DoesEntityExist(chicken) then
                        local netId = NetworkGetNetworkIdFromEntity(chicken)
                        TriggerServerEvent('nbrp_chicken_harvest:tryCatch', netId)
                    end

                    ClearPedTasks(PlayerPedId())
                    ChickenHarvest.Busy = false
                end
            else
                ChickenHarvest.HideText()
            end
        else
            ChickenHarvest.HideText()
        end

        Wait(sleep)
    end
end)
