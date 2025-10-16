local webhook = "https://canary.discord.com/api/webhooks/1428388916678889504/JYWapRBuVes8x6FnDn7pZHDPGpk6h76LBgVXHFfly7yiC5i_d7flkASNpaW3sc_63URs"
local request = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
if not request then return end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

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
            footer = { text = "Server Monitor" }
        }}
    })
end

local function sendPlayerList()
    local players = Players:GetPlayers()
    local list = ""
    for i, p in ipairs(players) do
        list = list .. i .. ". " .. p.Name .. "\n"
    end
    sendEmbed("🟢 Server Monitoring", "List Player:\n" .. list .. "\nTotal player: " .. #players, 65280)
end

local sentJoin, sentLeave = {}
Players.PlayerAdded:Connect(function(player)
    if sentJoin[player.UserId] then return end
    sentJoin[player.UserId] = true
    sentLeave[player.UserId] = nil
    sendEmbed("🔵 Player Joined", player.Name .. " has joined the server.", 65280)
end)

Players.PlayerRemoving:Connect(function(player)
    if sentLeave[player.UserId] then return end
    sentLeave[player.UserId] = true
    sentJoin[player.UserId] = nil
    sendEmbed("🔴 Player Disconnected", player.Name .. " has left the server.", 16711680)
end)

task.spawn(function()
    sendPlayerList()
    while task.wait(600) do
        sendPlayerList()
    end
end)

local secretFishes = {
    ["Elshark Gran Maja"] = true,
    ["Robot Kraken"] = true,
    ["Bone Whale"] = true,
    ["Crystal Crab"] = true,
    ["Orca"] = true,
    ["Blob Shark"] = true,
    ["Ghost Shark"] = true,
    ["Worm Fish"] = true,
    ["Lochnes Monster"] = true,
    ["Eerie Shark"] = true,
    ["Monster Shark"] = true,
    ["Thin Armor Shark"] = true,
    ["Great Whale"] = true,
    ["Frostborn Shark"] = true,
    ["Queen Crab"] = true,
    ["King Crab"] = true,
    ["Panther Eel"] = true,
    ["Giant Squid"] = true,
    ["Ghost Worm Fish"] = true,
    ["Megalodon"] = true,
    ["King Jelly"] = true,
    ["Mosasaurus Shark"] = true
}

local debounce = {}
local debounceDelay = 8

local function sendFishNotif(username, fishName, weight)
    local now = os.time()
    debounce[username] = debounce[username] or {}
    if debounce[username][fishName] and now - debounce[username][fishName] < debounceDelay then return end
    debounce[username][fishName] = now
    local desc = string.format("Username: %s\nFish: %s\nWeight: %skg", username, fishName, weight or "Unknown")
    safeRequest({
        content = "@everyone",
        embeds = {{
            title = "🎣 Secret Fish Caught",
            description = desc,
            color = 16776960,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            footer = { text = "Fishing Monitor" }
        }}
    })
end

local function onChatMessage(text)
    local username, fish, weight = text:match("%[Server%]:%s*(%w+)%s+obtained a%s+([%w%s]+)%s*%(([%d%.]+)kg%)")
    if username and fish and weight then
        fish = fish:gsub("%s+$", "")
        if secretFishes[fish] then
            sendFishNotif(username, fish, weight)
        end
    end
end

task.spawn(function()
    local channels = TextChatService:WaitForChild("TextChannels")
    for _, channel in ipairs(channels:GetChildren()) do
        if channel.Name:lower():find("general") then
            channel.MessageReceived:Connect(function(message)
                onChatMessage(message.Text)
            end)
        end
    end
end)

for _, v in ipairs(Players:GetPlayers()) do
    debounce[v.Name] = {}
end
