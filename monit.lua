local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WebhookURL = "https://canary.discord.com/api/webhooks/1428367503289094184/TPeXSzlP2N7zojBl5JLFH7Sfo7aOWzstld14r4enJvJrrgSK-VILrBcM-8fp_4Vjw6ma"

local function sendPlayerList()
    local playerNames = Players:GetPlayers()
    local playerList = ""
    for i, player in ipairs(playerNames) do
        playerList = playerList .. i .. ". " .. player.Name .. "\n"
    end

    local currentTime = os.date("!%Y-%m-%dT%H:%M:%S.000Z")

    local messageData = {
        ["embeds"] = {{
            ["title"] = "Server Monitoring",
            ["description"] = "List Player:\n" .. playerList .. "\nTotal current player count in this server: " .. #playerNames,
            ["color"] = 65280,
            ["timestamp"] = currentTime,
            ["footer"] = {
                ["text"] = "Last updated at UTC time"
            }
        }}
    }

    local jsonData = HttpService:JSONEncode(messageData)
    HttpService:PostAsync(WebhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
end

local function sendDisconnectNotification(playerName)
    local currentTime = os.date("!%Y-%m-%dT%H:%M:%S.000Z")

    local messageData = {
        ["embeds"] = {{
            ["title"] = "Player Disconnected",
            ["description"] = playerName .. " has left the server.",
            ["color"] = 16711680,
            ["timestamp"] = currentTime,
            ["footer"] = {
                ["text"] = "Disconnected at UTC time"
            }
        }}
    }

    local jsonData = HttpService:JSONEncode(messageData)
    HttpService:PostAsync(WebhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
end

Players.PlayerRemoving:Connect(function(player)
    sendDisconnectNotification(player.Name)
end)

while true do
    sendPlayerList()
    wait(600) -- 10 menit
end
