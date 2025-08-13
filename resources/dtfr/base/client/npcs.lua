local allNpcs = {};

local spawnNpc = function(data)
  local model = data.model;
  local pos = data.pos;
  local heading = data.heading or 90.0;
  local func = data.func;
  local minDist = data.minDistance or 1.0;
  local npcName = data.npcName or "Unknown";

  if not model or not pos or not func then
    return print("NPC model, position or function not found");
  end

  RequestModel(model);
  repeat Wait(0) until HasModelLoaded(model);

  local npc = CreatePed(0, model, pos.x, pos.y, pos.z-1, heading, false, false);
  FreezeEntityPosition(npc, true);
  SetEntityInvincible(npc, true);
  SetBlockingOfNonTemporaryEvents(npc, true);
  SetModelAsNoLongerNeeded(model);

  table.insert(allNpcs, {
    npc = npc;
    minDistance = minDist;
    func = func;
    pos = pos;
    npcName = npcName;
  });

  return npc;
end

exports("spawnNpc", spawnNpc);

CreateThread(function()
  while true do
    local ped = PlayerPedId();
    local coords = GetEntityCoords(ped);
    local sleep = 1000;

    for _, npcData in next, allNpcs do
      local dist = #(npcData.pos - coords);

      if dist < 6.0 then
        sleep = 0;
        DrawText3D(npcData.pos.x, npcData.pos.y, npcData.pos.z + 1.15, "~b~*NPC* \n ~w~" .. npcData.npcName, dist);

        if dist < npcData.minDistance then
          if IsControlJustReleased(0, 38) then
            npcData.func();
          end
        end
      end
    end
    Wait(sleep);
  end
end)

AddEventHandler("onResourceStop", function(resource)
  if resource == GetCurrentResourceName() then
    for _, npc in next, allNpcs do
      DeleteEntity(npc.npc);
    end
    allNpcs = {};
  end
end)
