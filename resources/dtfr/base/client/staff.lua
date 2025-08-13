RegisterNetEvent("client:spawnVehicle", function(veh)
  local veh_hash = GetHashKey(veh);

  RequestModel(veh_hash);
  while not HasModelLoaded(veh_hash) do
    Wait(0);
  end

  local playerPed = PlayerPedId();
  local pedCoords = GetEntityCoords(playerPed);
  local pedHeading = GetEntityHeading(playerPed);

  local veh = CreateVehicle(veh_hash, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, true, true);

  SetPedIntoVehicle(playerPed, veh, -1);
  SetVehicleOnGroundProperly(veh);
  SetVehicleNumberPlateText(veh, "SpawnVeh");
  SetModelAsNoLongerNeeded(veh_hash);
end)

RegisterNetEvent("client:deleteVehicle", function()
  local playerPed = PlayerPedId();
  local pedVeh = GetVehiclePedIsIn(playerPed, false);

  if pedVeh == 0 then
    return Utils['Notify']("You are not in a vehicle", "error");
  end

  DeleteEntity(pedVeh);
  Utils['Notify']("Vehicle deleted", "success");
end)

local noClipConfig = {
    controls = {
        closeKey = 73,
        goUp = 85,
        goDown = 48,
        turnLeft = 34,
        turnRight = 35,
        goForward = 32,
        goBackward = 33,
        changeSpeed = 21,
        changeSpeedDown = 36,
        togInvisibiliy = 23
    },

    speeds = {
        { speed = 0.05},
        { speed = 0.4},
        { speed = 2},
        { speed = 4},
        { speed = 6},
        { speed = 10},
        { speed = 20},
        { speed = 45}
    },

    offsets = {
        y = 0.5,
        z = 0.2,
        h = 3,
    },

    bgR = 0,
    bgG = 0,
    bgB = 0,
    bgA = 140,
}
local noclipActive, index, noclipEntity, noclipInvisibility = false, 2, nil, false

local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(6)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, noClipConfig.controls.closeKey, true))
    ButtonMessage("Inchide No-Clip")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, noClipConfig.controls.goUp, true))
    ButtonMessage("Sus")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, noClipConfig.controls.goDown, true))
    ButtonMessage("Jos")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, noClipConfig.controls.turnRight, true))
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, noClipConfig.controls.turnLeft, true))
    ButtonMessage("Stanga / Dreapta")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, noClipConfig.controls.goBackward, true))
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, noClipConfig.controls.goForward, true))
    ButtonMessage("Fata / Spate")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, noClipConfig.controls.togInvisibiliy, true))
    ButtonMessage("Invizibilitate")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    ButtonMessage("Viteza ("..index..")")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(noClipConfig.bgR)
    PushScaleformMovieFunctionParameterInt(noClipConfig.bgG)
    PushScaleformMovieFunctionParameterInt(noClipConfig.bgB)
    PushScaleformMovieFunctionParameterInt(noClipConfig.bgA)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

local function toggleNoclipHandler()
    local pedId = PlayerPedId()
    noclipActive = not noclipActive

    if IsPedInAnyVehicle(pedId, false) then
        noclipEntity = GetVehiclePedIsIn(pedId, false)
    else
        noclipEntity = pedId
    end

    SetEntityCollision(noclipEntity, not noclipActive, not noclipActive)
    FreezeEntityPosition(noclipEntity, noclipActive)
    SetEntityInvincible(noclipEntity, noclipActive)
    SetVehicleRadioEnabled(noclipEntity, not noclipActive)

    if noclipInvisibility then
        noclipInvisibility = false
        SetEntityVisible(noclipEntity, not noclipInvisibility)
        if noclipEntity ~= PlayerPedId() then
            SetEntityVisible(PlayerPedId(), not noclipInvisibility)
        end
    end

    if not noclipActive then
        return
    end

    local buttons = setupScaleform("instructional_buttons")
    local currentSpeed = noClipConfig.speeds[index].speed

    while noclipActive do
        Citizen.Wait(1)

        if IsDisabledControlJustPressed(1, noClipConfig.controls.closeKey) then
            toggleNoclipHandler()
        end

        DrawScaleformMovieFullscreen(buttons)

        local yoff = 0.0
        local zoff = 0.0

        if IsControlJustPressed(1, noClipConfig.controls.changeSpeed) then
            if index ~= #noClipConfig.speeds then
                index = index+1
                currentSpeed = noClipConfig.speeds[index].speed
            else
                currentSpeed = noClipConfig.speeds[1].speed
                index = 1
            end
            setupScaleform("instructional_buttons")
        end

        if IsDisabledControlJustPressed(1, noClipConfig.controls.changeSpeedDown) then
            if index == 1 then
                index = #noClipConfig.speeds
                currentSpeed = noClipConfig.speeds[index].speed
            else
                index = index - 1
                currentSpeed = noClipConfig.speeds[index].speed
            end
            setupScaleform("instructional_buttons")
        end

        DisableControlAction(0, 23, true)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 35, true)
        DisableControlAction(0, 266, true)
        DisableControlAction(0, 267, true)
        DisableControlAction(0, 268, true)
        DisableControlAction(0, 269, true)
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 20, true)
        DisableControlAction(0, 73, true)
        DisableControlAction(0, 74, true)
        DisableControlAction(0, 75, true)

        if IsDisabledControlPressed(0, noClipConfig.controls.goForward) then
            yoff = noClipConfig.offsets.y
        end

        if IsDisabledControlPressed(0, noClipConfig.controls.goBackward) then
            yoff = -noClipConfig.offsets.y
        end

        if IsDisabledControlPressed(0, noClipConfig.controls.turnLeft) then
            local amm = index == 1 and 1 or noClipConfig.offsets.h
            SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity)+amm)
        end

        if IsDisabledControlPressed(0, noClipConfig.controls.turnRight) then
            local amm = index == 1 and 1 or noClipConfig.offsets.h
            SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity)-amm)
        end

        if IsDisabledControlPressed(0, noClipConfig.controls.goUp) then
            zoff = noClipConfig.offsets.z
        end

        if IsDisabledControlPressed(0, noClipConfig.controls.goDown) then
            zoff = -noClipConfig.offsets.z
        end

        if IsDisabledControlJustPressed(0, noClipConfig.controls.togInvisibiliy) then
            noclipInvisibility = not noclipInvisibility

            SetEntityVisible(noclipEntity, not noclipInvisibility)
            if noclipEntity ~= PlayerPedId() then
                SetEntityVisible(PlayerPedId(), not noclipInvisibility)
            end
        end

        local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * currentSpeed, zoff * currentSpeed)
        local heading = GetEntityHeading(noclipEntity)
        SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
        SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
        SetEntityHeading(noclipEntity, heading)
        SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, noclipActive, noclipActive, noclipActive)
    end
end

RegisterNetEvent("client:toggleNoclip", toggleNoclipHandler);
