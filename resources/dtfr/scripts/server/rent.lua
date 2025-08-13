RegisterNetEvent("rent:startRent", function()
  local _src = source;
  local user = dFR:getUser(_src);

  if not user then
    return;
  end

  local userMoney = user:getMoney().cash;

  if not user:takeCash(Rent.Settings.rentPrice) then
    return Utils['Notify']("You do not have enough money to rent a vehicle", "error", _src);
  end

  Utils['Notify']("You have rented a vehicle for 10 minutes!", "success", _src);
  TriggerClientEvent("rent:createVeh", _src);

  Citizen.SetTimeout(600000, function()
    Utils['Notify']("Your vehicle has been returned!", "success", _src);
    TriggerClientEvent("rent:deleteVeh", _src);
  end)
end)
