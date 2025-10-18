local webhook = "https://canary.discord.com/api/webhooks/1428388916678889504/JYWapRBuVes8x6FnDn7pZHDPGpk6h76LBgVXHFfly7yiC5i_d7flkASNpaW3sc_63URs"
local request = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
if not request then return end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

local monitoringDisconnected = false

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

local function getServerLuck()
    local success, luckText, timerText = pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return "No Luck Active", "Unknown" end

        local eventsFrame = playerGui:FindFirstChild("Events") and playerGui.Events:FindFirstChild("Frame")
        local multiplier = "No Luck Active"
        if eventsFrame then
            local serverLuck = eventsFrame:FindFirstChild("Server Luck")
            if serverLuck and serverLuck:FindFirstChild("Server") then
                local luckLabel = serverLuck.Server:FindFirstChild("LuckCounter")
                if luckLabel and luckLabel.Text and luckLabel.Text ~= "" then
                    multiplier = luckLabel.Text
                end
            end
        end

        local store = playerGui:FindFirstChild("Exclusive Store")
        local timer = "Unknown"
        if store and store:FindFirstChild("Main") then
            local item = store.Main.Content.Items:FindFirstChild("Server Luck")
            local inside = item and item:FindFirstChild("Inside")
            local timerLabel = inside and inside:FindFirstChild("Timer")
            if timerLabel and timerLabel.Text and timerLabel.Text ~= "" then
                timer = timerLabel.Text
            end
        end

        return multiplier, timer
    end)

    if success then
        return luckText or "No Luck Active", timerText or "Unknown"
    end
    return "No Luck Active", "Unknown"
end

local function getCurrentEvents()
    local success, eventsList = pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return "None" end

        local eventsFrame = playerGui:FindFirstChild("Events")
        if not eventsFrame or not eventsFrame:FindFirstChild("Frame") then return "None" end

        local eventsContainer = eventsFrame.Frame:FindFirstChild("Events")
        if not eventsContainer then return "None" end

        local activeEvents = {}
        for _, eventFrame in ipairs(eventsContainer:GetChildren()) do
            if eventFrame:IsA("Frame") or eventFrame:IsA("GuiObject") then
                local eventName = eventFrame.Name
                if eventName and eventName ~= "" then
                    table.insert(activeEvents, eventName)
                end
            end
        end

        if #activeEvents == 0 then
            return "None"
        end

        return table.concat(activeEvents, ", ")
    end)

    if success and eventsList then
        return eventsList
    end
    return "None"
end

local function sendPlayerList()
    local players = Players:GetPlayers()
    local list = ""
    for i, p in ipairs(players) do
        list = list .. i .. ". " .. p.DisplayName .. " (@" .. p.Name .. ")\n"
    end
    local luck, timer = getServerLuck()
    local events = getCurrentEvents()
    
    local desc = "<:players:1365290081937526834> Player Online:\n" .. list .. "\n<:stats:1365955343221264564> Total player: " .. #players .. "\n🍀 Current Server Luck: " .. luck
    if luck ~= "No Luck Active" then
        desc = desc .. " (" .. timer .. ")"
    end
    desc = desc .. "\n🎉 Current Events: " .. events
    
    sendEmbed("<:emoji_41:1377279038200086660> Server Monitoring", desc, 65280)
end

sendEmbed("<:changes:1365295949811028068> Monitoring Account Reconnected", LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ") has joined the server.", 65280)

local sentJoin, sentLeave = {}, {}

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        sentJoin[player.UserId] = true
    end
end

Players.PlayerAdded:Connect(function(player)
    if monitoringDisconnected then return end
    task.wait(0.5)
    if player == LocalPlayer then return end
    if sentJoin[player.UserId] then return end
    sentJoin[player.UserId] = true
    sentLeave[player.UserId] = nil
    sendEmbed("🔵 Player Joined", player.DisplayName .. " (@" .. player.Name .. ") has joined the server.", 65280)
end)

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        monitoringDisconnected = true
        sendEmbed("⚠️ Monitoring Account Disconnected", LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ") has disconnected from the server.", 16753920)
        return
    end
    if monitoringDisconnected then return end
    if sentLeave[player.UserId] then return end
    sentLeave[player.UserId] = true
    sentJoin[player.UserId] = nil
    sendEmbed("🔴 Player Disconnected", player.DisplayName .. " (@" .. player.Name .. ") has left the server.", 16711680)
end)

task.spawn(function()
    sendPlayerList()
    while task.wait(300) do
        if monitoringDisconnected then break end
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
    ["Mosasaurus Shark"] = true,
    ["Big Narwhal"] = true,
    ["Narwhal"] = true
}

local debounce = {}
local debounceDelay = 8

local function sendFishNotif(username, fishName, weight, chance)
    if monitoringDisconnected then return end
    local now = os.time()
    debounce[username] = debounce[username] or {}
    if debounce[username][fishName] and now - debounce[username][fishName] < debounceDelay then return end
    debounce[username][fishName] = now
    local desc = string.format("Username: %s\nFish: %s\nWeight: %s\nChance: %s", username, fishName, weight or "Unknown", chance or "Unknown")
    safeRequest({
        content = "@everyone",
        embeds = {{
            title = "<:fish:1365955309524353024> Secret Fish Caught",
            description = desc,
            color = 16776960,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            footer = { text = "Fishing Monitor" }
        }}
    })
end

local function onChatMessage(text)
    if monitoringDisconnected then return end
    local username, fishName, weight, chance = text:match("%[Server%]:%s*(%S+)%s+obtained%s+a%s+(.-)%s*%((.-)%)%s+with%s+a%s+(.-)%s+chance!")
    
    if username and fishName and weight then
        fishName = fishName:gsub("^%s*(.-)%s*$", "%1")
        
        if secretFishes[fishName] then
            sendFishNotif(username, fishName, weight, chance or "Unknown")
        end
    end
end

task.spawn(function()
    local success = pcall(function()
        local channels = TextChatService:WaitForChild("TextChannels", 10)
        if channels then
            for _, channel in ipairs(channels:GetChildren()) do
                if channel.Name == "RBXGeneral" then
                    channel.MessageReceived:Connect(function(message)
                        if monitoringDisconnected then return end
                        pcall(function()
                            onChatMessage(message.Text)
                        end)
                    end)
                end
            end
        end
    end)
    
    if not success then
        warn("Failed to connect to General chat channel")
    end
end)

for _, v in ipairs(Players:GetPlayers()) do
    debounce[v.Name] = {}
end
