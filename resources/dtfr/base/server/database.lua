DB = {};

Citizen.CreateThread(function()
    local q = [[
        CREATE TABLE IF NOT EXISTS `dt_users` (
            `userLicence` VARCHAR(128) NOT NULL,
            `user_id` INT AUTO_INCREMENT PRIMARY KEY,
            `userName` VARCHAR(64) NOT NULL,
            `userData` TEXT
        )
    ]];
    exports['oxmysql']:execute(q);
end)

DB['findUserByLicense'] = function(userLicence, cb)
    exports['oxmysql']:query("SELECT * FROM dt_users WHERE userLicence = ?", {userLicence}, function(result)
        if result and result[1] then
           return cb:resolve(result[1]);
        else
           return cb:resolve(false);
        end
    end)
end

DB['findUserById'] = function(id, cb)
    exports['oxmysql']:query("SELECT * FROM dt_users WHERE user_id = ?", {id}, function(result)
        if result and result[1] then
           return cb:resolve(result[1]);
        else
           return cb:resolve(false);
        end
    end)
end

DB['createUser'] = function(userLicence,userName,cb)
    if not userLicence or not userName then
        return;
    end

    exports['oxmysql']:query("SELECT * FROM dt_users", function(result)
        if result then
            local new_user_id = #result + 1;

            exports['oxmysql']:execute("INSERT INTO dt_users (userLicence, user_id , userName, userData) VALUES (?, ?, ?, ?)",{userLicence,new_user_id,userName,json.encode({})}, function(insert)
              if insert and insert.affectedRows >= 1 then
                  return cb:resolve({ user_id = new_user_id, userName = userName, user_licence = userLicence, userData = {}});
              end
            end)
        end
    end)
end

DB['saveUserData'] = function(source)
    local _src = source;

    if not _src then
      return;
    end

    local userLicence = GetPlayerIdentifierByType(_src, 'license'):gsub('license:', '');

    if not userLicence then
      return;
    end

    local user = dFR:getUser(source);
    if not user then
      return;
    end

    exports['oxmysql']:execute("UPDATE dt_users SET userData = ? WHERE userLicence = ?", {json.encode(user.data), userLicence});
end

DB['offlineSaveData'] = function(user_id, key, value)
  local dbTarget = promise.new();
  DB['findUserById'](user_id, dbTarget);
  local target_user = Citizen.Await(dbTarget);

  if not target_user then
    return 'User not found in db!';
  end

  local userData = json.decode(target_user.userData) or {};
  userData[key] = value;

  exports['oxmysql']:execute("UPDATE dt_users SET userData = ? WHERE user_id = ?", {json.encode(userData), user_id});

  return 'User data saved successfully';
end
