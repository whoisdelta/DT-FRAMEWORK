local veh;

RegisterNetEvent("rent:createVeh", function()
  local vehHash = GetHashKey(Rent.Settings.rentVeh);
  local playerPed = PlayerPedId();
  local vehSpawnCoords = Rent.Settings.rentVehSpawn;

  RequestModel(vehHash);
  while not HasModelLoaded(vehHash) do
    Wait(0);
  end

  veh = CreateVehicle(vehHash, vehSpawnCoords.x, vehSpawnCoords.y, vehSpawnCoords.z, 0.0, true, true);
  SetEntityAsMissionEntity(veh, true, true);
  SetVehicleOnGroundProperly(veh);
  SetModelAsNoLongerNeeded(vehHash);
  SetVehicleNumberPlateText(veh, "RENT");
  SetPedIntoVehicle(playerPed, veh, -1);
end)

RegisterNetEvent("rent:deleteVeh", function()
  if DoesEntityExist(veh) then
    DeleteEntity(veh);
    veh = nil;
  end
end)

CreateThread(function()
  exports[GetCurrentResourceName()]:spawnNpc({
    pos = Rent.Settings.npcPos;
    model = Rent.Settings.npcModel;
    func = function()
      TriggerServerEvent("rent:startRent");
    end;
    heading = 180.0;
    minDistance = 2.0;
    npcName = "RENT";
  });
end)
