dFR = {};
dFR.User = {};
dFR.users_data = {};
dFR.user_fromuid = {};
dFR.connecting_users = {};

local User = {};
User.__index = User;

function User.new(data)
    local self = setmetatable({}, User);

    self.source = data.source;
    self.id = data.id;
    self.name = data.name or GetPlayerName(data.source);
    self.endpoint = data.endpoint or GetPlayerEndpoint(data.source);
    self.data = data.data or {};

    for k, v in pairs(dFR.User) do
        self[k] = v;
    end

    return self;
end

function User:__index(index)
    local method = dFR.User[index];

    if method then
        return function(_, ...)
            return method(self, ...);
        end
    end

    local export = userExps[index];
    if export then
        return function(_, ...)
            return dFR:callUserFunc(self.source, index, ...);
        end
    end

    local value = self:get(index);
    if value then
        self[index] = value;
        return value;
    end
end

function dFR:getUser(source)
    return self.users_data[source];
end

function dFR:getUserById(userId)
    return self.users_data[self.user_fromuid[userId]];
end

function dFR:getUserId(source)
    return self.users_data[source] and self.users_data[source].id or nil;
end

function dFR:getUserSource(userId)
    return self.user_fromuid[userId];
end

function dFR:getUsers()
    local users = {}
    for k, v in pairs(self.user_fromuid) do
        users[k] = v;
    end
    return users;
end

function dFR:connectUser(source)
    local identifier = GetPlayerIdentifierByType(source, 'license'):gsub('license:', '');
    if not identifier then
      return nil;
    end

    local userData = self.connecting_users[identifier];
    if not userData then
      return nil;
    end

    self.connecting_users[identifier] = nil;

    local user = User.new({
        source = source,
        id = userData.user_id,
        name = GetPlayerName(source),
        endpoint = GetPlayerEndpoint(source),
        data = type(userData.userData) == 'string' and json.decode(userData.userData) or userData.userData or {}
    });

    if not user.data.money then
      user.data.money = Money.defaultMoney;
    end

    self.users_data[source] = user;
    self.user_fromuid[user.id] = source;

    return user;
end

function dFR:disconnectUser(source, reason)
    local user = self:getUser(source);
    if not user then
      return;
    end

    local reason = reason or 'Unknown';
    print(('[dTFR] %s (%s) disconnected (userId = %d) Reason: %s'):format(user.name, user.endpoint, user.id, reason));

    local playerPos = user:getCoords();

    user:set('dsc_pos', {
      x = playerPos.x,
      y = playerPos.y,
      z = playerPos.z
    });

    if DB and DB.saveUserData then
        DB.saveUserData(source);
    end

    self.users_data[source] = nil;
    self.user_fromuid[user.id] = nil;

    TriggerEvent('dFR:playerDisconnect', user, reason);
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local source = source;
    deferrals.defer();

    Wait(0);

    -- present cardu (join discord youtube plm);
    local join_server = promise.new();

    deferrals.presentCard(PresentCards.joiningCard, function(data)
      if data and data.action == "join_server" then
        join_server:resolve(data);
      else
        join_server:reject("Card dismissed without joining");
      end
    end);

    local success, result = pcall(function()
      return Citizen.Await(join_server);
    end);

    if not success then
      deferrals.done('Failed to join server');
      return;
    end
    -- present cardu (join discord youtube plm);

    deferrals.update('Checking license...');

    local identifier = GetPlayerIdentifierByType(source, 'license'):gsub('license:', '');
    if not identifier then
        deferrals.done('License not found.');
        return;
    end

    deferrals.update('Loading user data...');

    local dbCb = promise.new();
    DB['findUserByLicense'](identifier, dbCb);
    local userData = Citizen.Await(dbCb);

    if not userData then
        local createCb = promise.new();
        DB['createUser'](identifier, playerName, createCb);
        userData = Citizen.Await(createCb);

        if not userData then
            deferrals.done('Failed to create user.');
            return;
        end
    end

    deferrals.update('Verificam daca esti banat...');

    local decodedData = type(userData.userData) == 'string' and json.decode(userData.userData) or userData.userData;
    if decodedData and decodedData.ban_data then
        deferrals.done(dFR.User:banMsg(decodedData.ban_data.reason, decodedData.ban_data.banned_by));
        return;
    end

    dFR.connecting_users[identifier] = userData;
    deferrals.done();
end)

AddEventHandler('playerDropped', function(reason)
    local source = source;
    dFR:disconnectUser(source, reason);
end)

RegisterNetEvent('dFR:playerSpawned')
AddEventHandler('dFR:playerSpawned', function()
    local source = source;
    local user = dFR:getUser(source);
    if not user then
        user = dFR:connectUser(source);
    end

    if user then
      Citizen.SetTimeout(150, function()
        TriggerEvent('dFR:playerSpawn', user, not Player(user.source).state.user_id);
        print(('[dTFR] %s (%s) spawned (userId = %d)'):format(user.name, user.endpoint, user.id));
      end)
    end
end)

exports('getUser', function(source)
    return dFR:getUser(source);
end)

exports('getUserById', function(userId)
    return dFR:getUserById(userId);
end)

exports('getUserId', function(source)
    return dFR:getUserId(source);
end)

exports('getUserSource', function(userId)
    return dFR:getUserSource(userId);
end)

exports('getUsers', function()
    return dFR:getUsers();
end)

function dFR.User:getPed()
    return GetPlayerPed(self.source);
end

function dFR.User:getCoords()
    return GetEntityCoords(self:getPed());
end

function dFR.User:getName()
    return self.name;
end

function dFR.User:getId()
    return self.id;
end

function dFR.User:getSource()
    return self.source;
end

function dFR.User:getEndpoint()
    return self.endpoint;
end

function dFR.User:kick(reason)
    DropPlayer(self.source, reason or 'Kicked by admin');
end

function dFR.User:banMsg(reason, bannedBy)
    local msg = string.format(
      [[
        You have been banned from %s

        Reason: %s
        Duration: %s
        Banned by: %s

        Appeal: %s]],
        serverData.serverName or "DT-FRAMEWORK",
        reason or "No reason provided",
        "Permanent",
        bannedBy or "System",
        serverData.serverDiscord or "Contact staff"
    );

    return msg;
end

function dFR.User:ban(reason,banned_by)
  local reason = reason or 'Banned by server';

  self:set("ban_data", {
    reason = reason,
    banned_by = banned_by,
  })

  DropPlayer(self.source, "\n Banned from server \n Reason: " .. reason .. "\n Banned by: " .. banned_by);
end

function dFR.User:isOnline()
    return GetPlayerEndpoint(self.source) ~= nil;
end

function dFR.User:save()
    if DB and DB.saveUserData then
        DB.saveUserData(self.source);
        return true;
    end
    return false;
end

local function initPlayer(source)
    local id = GetPlayerIdentifierByType(source, 'license');
    if not id then return end

    id = id:gsub('license:', '');

    local cb = promise.new();
    DB['findUserByLicense'](id, cb);
    local userData = Citizen.Await(cb);

    if userData then
        dFR.connecting_users[id] = userData;

        Citizen.SetTimeout(50, function()
            local user = dFR:connectUser(source);
            if user then
                TriggerEvent('dFR:playerSpawn', user, true);
                print(('[dTFR] %s (%s) loaded (userId = %d)'):format(user.name, user.endpoint, user.id));
            end
        end)
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        print('[dTFR] Framework initialized successfully!');
        print('[dTFR] User system ready.');

        for k, v in pairs(GetPlayers()) do
            Wait(100);
            initPlayer(k);
        end
    end
end)
