local userExps = {};

setmetatable(dFR.User, {
    __newindex = function(self, key, value)
        local localFunction = (key:sub(1, 1) == '_') and key:sub(2);
        key = localFunction or key;

        rawset(self, key, value);

        if localFunction then return end
        userExps[key] = true;
    end
});

function dFR:getUserExps()
    return userExps;
end

function dFR:callUserFunc(source, func, ...)
    local user = self:getUser(source);
    if not user then return end
    return dFR.User[func](user, ...);
end

function dFR.User:set(key, value)
    if not self.data then
        self.data = {};
    end

    self.data[key] = value;
end

function dFR.User:get(key)
    if not self.data then
        return nil;
    end
    return self.data[key] or nil;
end
