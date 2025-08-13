Utils = {
  Notify = function(msg,type,src)
    if src then
      TriggerClientEvent("notify:addNotify",src,msg,type);
      return;
    end
    TriggerEvent("notify:addNotify",msg,type);
  end
};
