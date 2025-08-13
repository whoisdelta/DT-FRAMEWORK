RegisterNetEvent("dFR:playerSpawn");
local playerSpawn = function(user,first_spawn)
  local user_data = dFR:getUser(user.source);

  if first_spawn then
    if user_data:get('dsc_pos') then
      SetEntityCoords(user:getPed(), user_data:get('dsc_pos').x, user_data:get('dsc_pos').y, user_data:get('dsc_pos').z);
    end

    if not Player(user.source).state.user_id then
      Player(user.source).state:set('user_id', user.id, true);
    end
    return;
  end

  local respawn_coords = Spawn.DefaultSpawn.respawnCoords;
  if respawn_coords then
    if user_data:takeBank(250) then
      TriggerClientEvent('client:setHealth', user.source, 200);
    else
      Utils['Notify']("You do not have enough money to full recharge ur health!", "error", user.source);
      TriggerClientEvent('client:setHealth', user.source, 100);
    end
    SetEntityCoords(user:getPed(), respawn_coords.x, respawn_coords.y, respawn_coords.z);
    Utils['Notify']("You have been respawned at the hospital!", "success", user.source);
  end

end; AddEventHandler("dFR:playerSpawn", playerSpawn);
