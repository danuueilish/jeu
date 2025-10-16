local webhook = "https://canary.discord.com/api/webhooks/1428367503289094184/TPeXSzlP2N7zojBl5JLFH7Sfo7aOWzstld14r4enJvJrrgSK-VILrBcM-8fp_4Vjw6ma"

local request = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
if not request then
    warn("Executor kamu tidak mendukung HTTP request!")
    return
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local function safeRequest(tbl)
    pcall(function()
        request({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(tbl)
        })
    end)
end

local function sendEmbed(title, desc, color)
    safeRequest({
        embeds = {{
            title = title,
            description = desc,
            color = color,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            footer = {text = "Server Monitor"}
        }}
    })
end

local sentLeave = {}
local sentJoin = {}

local function sendPlayerList()
    local players = Players:GetPlayers()
    local list = ""
    for i, p in ipairs(players) do
        list = list .. i .. ". " .. p.Name .. "\n"
    end
    local msg = "List Player:\n" .. list .. "\nTotal player: " .. #players
    sendEmbed("Server Monitoring", msg, 65280)
end

Players.PlayerAdded:Connect(function(player)
    if sentJoin[player.UserId] then return end
    sentJoin[player.UserId] = true
    sentLeave[player.UserId] = nil
    sendEmbed("Player Joined", player.Name .. " has joined the server.", 65280)
end)

Players.PlayerRemoving:Connect(function(player)
    if sentLeave[player.UserId] then return end
    sentLeave[player.UserId] = true
    sentJoin[player.UserId] = nil
    sendEmbed("Player Disconnected", player.Name .. " has left the server.", 16711680)
end)

task.spawn(function()
    sendPlayerList()
    while task.wait(600) do
        sendPlayerList()
    end
end)
