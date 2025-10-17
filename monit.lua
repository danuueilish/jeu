local webhook = "https://canary.discord.com/api/webhooks/1428388916678889504/JYWapRBuVes8x6FnDn7pZHDPGpk6h76LBgVXHFfly7yiC5i_d7flkASNpaW3sc_63URs"
local request = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
if not request then return end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

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

local function sendPlayerList()
    local players = Players:GetPlayers()
    local list = ""
    for i, p in ipairs(players) do
        list = list .. i .. ". " .. p.DisplayName .. " (@" .. p.Name .. ")\n"
    end
    local luck, timer = getServerLuck()
    local desc = "Player Online:\n" .. list .. "\n\nTotal player: " .. #players .. "\nCurrent Server Luck: " .. luck
    if luck ~= "No Luck Active" then
        desc = desc .. " (" .. timer .. ")"
    end
    sendEmbed("🟢 Server Monitoring", desc, 65280)
end

local monitoringDisconnected = false
local sentJoin, sentLeave = {}, {}

-- Perbaikan: Track player yang sudah ada saat script dimulai
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        sentJoin[player.UserId] = true
    end
end

Players.PlayerAdded:Connect(function(player)
    task.wait(0.5) -- Delay sedikit untuk memastikan player benar-benar joined
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
    if sentLeave[player.UserId] then return end
    sentLeave[player.UserId] = true
    sentJoin[player.UserId] = nil
    sendEmbed("🔴 Player Disconnected", player.DisplayName .. " (@" .. player.Name .. ") has left the server.", 16711680)
end)

Players.PlayerAdded:Connect(function(player)
    if monitoringDisconnected and player == LocalPlayer then
        monitoringDisconnected = false
        sendEmbed("✅ Monitoring Account Reconnected", LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ") has reconnected to the server.", 65280)
    end
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

-- ========== COMMAND TESTING UNTUK CONSOLE ==========
_G.testMonitoring = function()
    print("Testing: Sending monitoring player list to Discord...")
    sendPlayerList()
    print("Monitoring test sent! Check your Discord webhook.")
end

_G.testJoined = function()
    print("Testing: Sending player joined notification to Discord...")
    local testPlayer = Players:GetPlayers()[1] or LocalPlayer
    sendEmbed("🔵 Player Joined", testPlayer.DisplayName .. " (@" .. testPlayer.Name .. ") has joined the server. [TEST]", 65280)
    print("Player joined test sent! Check your Discord webhook.")
end

_G.testDisconnected = function()
    print("Testing: Sending player disconnected notification to Discord...")
    local testPlayer = Players:GetPlayers()[1] or LocalPlayer
    sendEmbed("🔴 Player Disconnected", testPlayer.DisplayName .. " (@" .. testPlayer.Name .. ") has left the server. [TEST]", 16711680)
    print("Player disconnected test sent! Check your Discord webhook.")
end

_G.testSecretFish = function()
    print("Testing: Sending secret fish notification to Discord...")
    local testPlayer = Players:GetPlayers()[1] or LocalPlayer
    local desc = string.format("Username: %s\nFish: %s\nWeight: %skg\n[TEST]", testPlayer.Name, "Megalodon", "999.99")
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
    print("Secret fish test sent! Check your Discord webhook.")
end

print("========================================")
print("Discord Webhook Monitor Loaded!")
print("========================================")
print("Available test commands:")
print("1. testMonitoring() - Test monitoring player list")
print("2. testJoined() - Test player joined notification")
print("3. testDisconnected() - Test player disconnected notification")
print("4. testSecretFish() - Test secret fish notification")
print("========================================")
print("Example: Type in console: testMonitoring()")
print("========================================")
