allBlips = {};

Citizen.CreateThread(function()
  for _, blipData in next, Blips.Default do
    local blip = AddBlipForCoord(blipData.pos.x, blipData.pos.y, blipData.pos.z);
    SetBlipSprite(blip, blipData.blipId);
    SetBlipColour(blip, blipData.blipColor);
    SetBlipScale(blip, blipData.blipScale);
    SetBlipAsShortRange(blip, true);
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString(blipData.blipName);
    EndTextCommandSetBlipName(blip);

    table.insert(allBlips, blip);
  end
end)

AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    for _, blip in next, allBlips do
      RemoveBlip(blip);
    end
  end
end)
