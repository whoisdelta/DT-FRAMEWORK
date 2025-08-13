local maxAdminLevel <const> = 9;

function dFR.User:setStaff(level)
  if level == 0 then
    return self:set("user_staff", nil);
  end

  if level > maxAdminLevel then
    level = maxAdminLevel;
  end

  self:set("user_staff", {
    staff_level = level;
    staff_string = "Admin " .. level;
    added_at = os.date("%Y-%m-%d %H:%M:%S");
  });
end

function dFR.User:hasStaffLevel(level)
  local staff = self:get("user_staff");

  if not staff or not staff.staff_level then
    return false;
  end

  return staff.staff_level >= level;
end

function dFR.User:isUserStaff()
  return self:get('user_staff') and self:get('user_staff').staff_level > 0;
end

function dFR.User:removeUserStaff()
  if not self:isUserStaff() then
    return false;
  end

  return self:set("user_staff", nil);
end

RegisterCommand("setStaff", function(source, args)
  local _src = source;
  if _src ~= 0 then return end

  local target_id = tonumber(args[1]);
  local level = tonumber(args[2]);

  if not target_id or not level then
    return print("Usage: /setStaff <target_id> <level>");
  end

  local target_user = dFR:getUserById(target_id);

  if not target_user then
    return print("User not found");
  end

  target_user:setStaff(level);
  print(("User %s (%s) has been set to staff level %d"):format(target_user:getName(), target_user:getEndpoint(), level));
end)

RegisterCommand("veh", function(source, args)
  local _src = source;
  local user = dFR:getUser(_src);

  if not user:isUserStaff() then
    return Utils['Notify']("You are not allowed to use this command", "error", _src);
  end

  local veh = args[1];

  if not veh then
    return Utils['Notify']("Usage: /veh <vehicle>", "error", _src);
  end

  TriggerClientEvent("client:spawnVehicle", _src, veh);
end)

RegisterCommand("dv", function(source, args)
  local _src = source;
  local user = dFR:getUser(_src);

  if not user:isUserStaff() then
    return Utils['Notify']("You are not allowed to use this command", "error", _src);
  end

  TriggerClientEvent("client:deleteVehicle", _src);
end)

local ncCommands = {
  "nc";
  "noclip";
};

for _, command in pairs(ncCommands) do
  RegisterCommand(tostring(command), function(source)
    local _src = source;
    local user = dFR:getUser(_src);

    if not user:isUserStaff() then
      return print("You are not allowed to use this command");
    end

    TriggerClientEvent("client:toggleNoclip", _src);
  end)
end

--

RegisterCommand("ban", function(source, args)
  local _src = source;

  if _src ~= 0 then
    local user = dFR:getUser(_src);
    if not user then
      return;
    end

    if not user:hasStaffLevel(7) then
      return Utils['Notify']("You are not allowed to use this command", "error", _src);
    end
  end

  local target_id = tonumber(args[1]);
  local reason = args[2];

  if not target_id or not reason then
    if _src == 0 then
      return print("Usage: ban <target_id> <reason>");
    else
      return Utils['Notify']("Usage: /ban <target_id> <reason>", "error", _src);
    end
  end

  local target_user = dFR:getUserById(target_id);
  if not target_user then
    if _src == 0 then
      return print("User not found");
    else
      return Utils['Notify']("User not found", "error", _src);
    end
  end

  local banned_by = _src == 0 and "Console" or (dFR:getUser(_src):getName() .. " (" .. dFR:getUser(_src):getId() .. ")");
  target_user:ban(reason, banned_by);

  if _src == 0 then
    print("User banned successfully");
  else
    Utils['Notify']("User banned successfully", "success", _src);
  end
end)

RegisterCommand("unban", function(source, args)
  local _src = source;

  if _src ~= 0 then
    local user = dFR:getUser(_src);
    if not user then
      return;
    end

    if not user:hasStaffLevel(7) then
      return Utils['Notify']("You are not allowed to use this command", "error", _src);
    end
  end

  local target_id = tonumber(args[1]);
  if not target_id then
    if _src == 0 then
      return print("Usage: unban <target_id>");
    else
      return Utils['Notify']("Usage: /unban <target_id>", "error", _src);
    end
  end

  local dbSaveCb = DB['offlineSaveData'](target_id, "ban_data", nil);

  if _src == 0 then
    print(dbSaveCb);
  else
    Utils['Notify'](dbSaveCb, "success", _src);
  end
end)
