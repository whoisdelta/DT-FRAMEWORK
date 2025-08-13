AddEventHandler("playerSpawned", function()
    TriggerServerEvent("dFR:playerSpawned");

    local defaultPed = 'mp_m_freemode_01';
    local model = GetHashKey(defaultPed);

    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model);
        while not HasModelLoaded(model) do
            Wait(0);
        end

        SetPlayerModel(PlayerId(), model);

        Wait(100);
        local playerPed = PlayerPedId();

        SetPedHeadBlendData(playerPed, 0, 0, 0, 15, 0, 0, 0, 1.0, 0, false);
        SetPedComponentVariation(playerPed, 11, 0, 11, 0);
        SetPedComponentVariation(playerPed, 8, 0, 1, 0);
        SetPedComponentVariation(playerPed, 6, 1, 2, 0);
        SetPedHeadOverlayColor(playerPed, 1, 1, 0, 0);
        SetPedHeadOverlayColor(playerPed, 2, 1, 0, 0);
        SetPedHeadOverlayColor(playerPed, 4, 2, 0, 0);
        SetPedHeadOverlayColor(playerPed, 5, 2, 0, 0);
        SetPedHeadOverlayColor(playerPed, 8, 2, 0, 0);
        SetPedHeadOverlayColor(playerPed, 10, 1, 0, 0);
        SetPedHeadOverlay(playerPed, 1, 0, 0.0);
        SetPedHairColor(playerPed, 1, 1);

        SetModelAsNoLongerNeeded(model);
    end
end)

RegisterCommand('coords', function()
  local coords = GetEntityCoords(PlayerPedId());
  TriggerEvent('client:copyClipboard', coords.x .. ',' .. coords.y .. ',' .. coords.z);
end)

RegisterNetEvent('client:setHealth', function(health)
  SetEntityHealth(PlayerPedId(), health);
end)

RegisterNetEvent('client:copyClipboard', function(text)
  SendNUIMessage({
    action = 'copyClipboard';
    text = text;
  });
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        SetPlayerHealthRechargeLimit(PlayerId(), 0.5)
        Wait(1000)
    end
end)

DrawText3D = function(x, y, z, text, distance)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)

    if onScreen then
        local opacityTransition = distance > 1 and math.cos((distance - 1) / 7 * math.pi) * 0.5 + 0.5 or 1.0
        local opacity = math.floor(255 * opacityTransition)
        opacity = math.max(0, math.min(255, opacity))

        SetTextScale(0.40, 0.40)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255,255,255, opacity)
        SetTextEntry("STRING")
        SetTextCentre(1)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
