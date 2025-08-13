PresentCards = PresentCards or {};

PresentCards.joiningCard = {
    type = "AdaptiveCard",

    body = {
       {
           type = "TextBlock",
           text = "DT-FRMEWORK",
           wrap = true,
           horizontalAlignment = "Center",
           separator = false,
           height = "auto",
           fontType = "Default",
           size = "Large",
           weight = "Bolder",
           color = "Light"
       },
       {
           type = "TextBlock",
           text = "Bine ai venit pe DT-FRAMEWORK alege una dintre optiunile de mai jos!",
           wrap = true,
           horizontalAlignment = "Center",
           separator = true,
           height = "stretch",
           fontType = "Default",
           size = "Medium",
           weight = "Bolder",
           color = "Light"
       }
    },

    actions = {
       {
            type = "Action.OpenUrl",
            title = "Discord",
            url = "https://discord.gg/dtstore",
            horizontalAlignment = "Center"
       },
        {
            type = "Action.OpenUrl",
            title = "YouTube",
            url = "https://discord.gg/dtstore",
            horizontalAlignment = "Center"
       },
       {
            type = "Action.Submit",
            title = "Join Server",
            horizontalAlignment = "Center",

            data = {
                action = "join_server"
            }
       }
    },

    horizontalAlignment = "Center",
    version = "1.2",

    ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
};
