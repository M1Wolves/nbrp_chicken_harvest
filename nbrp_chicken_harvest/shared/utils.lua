Utils = {}

function Utils.LoadModel(model)
    if not IsModelInCdimage(model) then
        return false
    end

    RequestModel(model)

    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(model) do
        Wait(50)

        if GetGameTimer() > timeout then
            return false
        end
    end

    return true
end

function Utils.RandomPointInRadius(center, radius)
    local angle = math.random() * math.pi * 2
    local dist = math.sqrt(math.random()) * radius

    local x = center.x + math.cos(angle) * dist
    local y = center.y + math.sin(angle) * dist
    local z = center.z + 25.0

    local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, z, false)

    if foundGround then
        z = groundZ
    else
        z = center.z
    end

    return vector3(x, y, z)
end
