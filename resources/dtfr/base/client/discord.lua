Citizen.CreateThread(function()
  local appId = 1404461117622718504;
  local buttons = {{0, "Website", "https://github.com/whoisdelta"}, {1, "Direct Connect", "https://github.com/whoisdelta"}};

  while true do
      SetDiscordAppId(appId);
      for indx, btnData in pairs(buttons) do
        SetDiscordRichPresenceAction(btnData[1], btnData[2], btnData[3]);
      end

      SetDiscordRichPresenceAsset('DT-FR');
      SetDiscordRichPresenceAssetText('discord.gg/dtstore');

      SetRichPresence("Online: "..#GetActivePlayers().." din 128 jucatori");

      Citizen.Wait(30000);
  end
end)
