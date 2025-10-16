local webhook = "https://canary.discord.com/api/webhooks/1428367503289094184/TPeXSzlP2N7zojBl5JLFH7Sfo7aOWzstld14r4enJvJrrgSK-VILrBcM-8fp_4Vjw6ma"
local request = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
if not request then return end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local function safeRequest(reqTable)
    local ok, res = pcall(function() return request(reqTable) end)
    if not ok then
        warn("HTTP request failed:", res)
        return false, res
    end
    return true, res
end

local function sendEmbed(title, description, color)
    local currentTime = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    local data = {
        embeds = {{
            title = title,
            description = description,
            color = color or 65280,
            timestamp = currentTime,
            footer = { text = "Server Monitor" }
        }}
    }
    local body = HttpService:JSONEncode(data)
    local ok, res = safeRequest({
        Url = webhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = body
    })
    return ok, res
end

local function sendPlayerList()
    local players = Players:GetPlayers()
    local list = ""
    for i, p in ipairs(players) do
        list = list .. i .. ". " .. p.Name .. "\n"
    end
    local desc = "List Player:\n" .. list .. "\nTotal player: " .. #players
    sendEmbed("Server Monitoring", desc, 65280)
end

Players.PlayerAdded:Connect(function(player)
    sendEmbed("Player Joined", player.Name .. " has joined the server.", 65280)
end)

Players.PlayerRemoving:Connect(function(player)
    sendEmbed("Player Disconnected", player.Name .. " has left the server.", 16711680)
end)

task.spawn(function()
    sendPlayerList()
    while true do
        task.wait(600)
        sendPlayerList()
    end
end)
