local maxCash <const> = 50000;

function dFR.User:getMoney()
  local money = self:get('money');
  return money;
end

function dFR.User:updateHud()
  local money = self:getMoney();
  TriggerClientEvent('vrp-hud:setHudData', self.source, money);
end

function dFR.User:giveCash(amount)
  local user_money = self:getMoney();
  local new_cash = user_money.cash + amount;

  if new_cash > maxCash then
    Utils['Notify']("You cannot have more than " .. maxCash .. " in cash!", "error");
    return false;
  end

  self:set('money', {
    cash = new_cash,
    bank = user_money.bank,
  });

  self:updateHud();
  return true;
end

function dFR.User:takeCash(amount)
  local user_money = self:getMoney();
  local new_cash = user_money.cash - amount;

  if new_cash <= 0 then
    return false;
  end

  self:set('money', {
    cash = new_cash,
    bank = user_money.bank,
  });

  self:updateHud();
  return true;
end

function dFR.User:giveBank(amount)
  local user_money = self:getMoney();
  local new_bank = user_money.bank + amount;

  self:set('money', {
    cash = user_money.cash,
    bank = new_bank,
  });

  self:updateHud();
  return true;
end

function dFR.User:takeBank(amount)
  local user_money = self:getMoney();
  local new_bank = user_money.bank - amount;

  if new_bank <= 0 then
    return false;
  end

  self:set('money', {
    cash = user_money.cash,
    bank = new_bank,
  });

  self:updateHud();
  return true;
end

RegisterCommand("setCash", function(source, args)
  local _src = source;
  local user = dFR:getUser(_src);

  if not user then
    return;
  end

  if not user:hasStaffLevel(7) then
    return Utils['Notify']("You do not have permission to use this command", "error", _src);
  end

  local target_id = tonumber(args[1]);
  local ammount = tonumber(args[2]);

  if not target_id or not ammount then
    return Utils['Notify']("Invalid target ID or amount", "error", _src);
  end

  local target_user = dFR:getUser(target_id);
  if not target_user then
    return Utils['Notify']("Target not found", "error", _src);
  end

  target_user:giveCash(ammount);
  Utils['Notify']("You have given " .. ammount .. " to " .. target_user:getName(), "success", _src);
  Utils['Notify']("You have received " .. ammount .. " from " .. user:getName(), "success", target_user.source);
end)

RegisterCommand("setBank", function(source, args)
  local _src = source;
  local user = dFR:getUser(_src);

  if not user then
    return;
  end

  if not user:hasStaffLevel(7) then
    return Utils['Notify']("You do not have permission to use this command", "error", _src);
  end

  local target_id = tonumber(args[1]);
  local ammount = tonumber(args[2]);

  if not target_id or not ammount then
    return Utils['Notify']("Invalid target ID or amount", "error", _src);
  end

  local target_user = dFR:getUser(target_id);
  if not target_user then
    return Utils['Notify']("Target not found", "error", _src);
  end

  target_user:giveBank(ammount);
  Utils['Notify']("You have given " .. ammount .. " to " .. target_user:getName(), "success", _src);
  Utils['Notify']("You have received " .. ammount .. " from " .. user:getName(), "success", target_user.source);
end)

local playerSpawn = function(user, first_spawn)
  if first_spawn then
    user:updateHud();
  end
end; AddEventHandler('dFR:playerSpawn', playerSpawn);
