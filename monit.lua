local webhook = "https://canary.discord.com/api/webhooks/1428367503289094184/TPeXSzlP2N7zojBl5JLFH7Sfo7aOWzstld14r4enJvJrrgSK-VILrBcM-8fp_4Vjw6ma"

local request = syn and syn.request or http_request or request or http and http.request
if not request then return end

local Players = game:GetService("Players")

local function sendEmbed(title, description, color)
    local currentTime = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["timestamp"] = currentTime,
            ["footer"] = {["text"] = "Server Monitor"}
        }}
    }
    request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode(data)
    })
end

local function sendPlayerList()
    local players = Players:GetPlayers()
    local list = ""
    for i, p in ipairs(players) do
        list = list .. i .. ". " .. p.Name .. "\n"
    end
    sendEmbed("Server Monitoring", "List Player:\n" .. list .. "\nTotal player: " .. #players, 65280)
end

Players.PlayerRemoving:Connect(function(player)
    sendEmbed("Player Disconnected", player.Name .. " has left the server.", 16711680)
end)

while task.wait(600) do
    sendPlayerList()
end

sendPlayerList()
