local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local request = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
if not request then
    warn("Executor kamu tidak mendukung HTTP request!")
    return
end


local webhookPlayers = "https://canary.discord.com/api/webhooks/1428388916678889504/JYWapRBuVes8x6FnDn7pZHDPGpk6h76LBgVXHFfly7yiC5i_d7flkASNpaW3sc_63URs"
local webhookFish = webhookPlayers
local LocalPlayer = Players.LocalPlayer

local function safeRequest(tbl)
    pcall(function()
        request({
            Url = webhookPlayers,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(tbl)
        })
    end)
end

local function safePost(tbl)
    pcall(function()
        request({
            Url = webhookFish,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
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
    sendEmbed("🟢 Server Monitoring", msg, 65280)
end

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

local fishTargets = {
    ["elshark gran maja"] = "Elshark Gran Maja",
    ["robot kraken"] = "Robot Kraken",
    ["bone whale"] = "Bone Whale"
}

local secretFishes = {
    ["Crystal Crab"] = true,
    ["Orca"] = true,
    ["Blob Shark"] = true,
    ["Ghost Shark"] = true,
    ["Worm Fish"] = true,
    ["Lochnes Monster"] = true,
    ["Eerie Shark"] = true,
    ["Monster Shark"] = true,
    ["Thin Armor Shark"] = true,
    ["Scare"] = true,
    ["Great Whale"] = true,
    ["Frostborn Shark"] = true,
    ["Queen Crab"] = true,
    ["King Crab"] = true,
    ["Panther Eel"] = true,
    ["Giant Squid"] = true,
    ["Robot Kraken"] = true,
    ["Ghost Worm Fish"] = true,
    ["Megalodon"] = true,
    ["King Jelly"] = true,
    ["Mosasaurus Shark"] = true,
    ["Elshark Gran Maja"] = true,
    ["Bone Whale"] = true
}

local debounceWindow = 8
local recent = {}

local function isPlayerInServer(playerName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == playerName then
            return true
        end
    end
    return false
end

local function sendFishNotif(username, fishName, weight)
    if not secretFishes[fishName] then
        return
    end
    if not isPlayerInServer(username) then
        return
    end
    weight = weight or "Unknown"
    local now = os.time()
    recent[username] = recent[username] or {}
    local last = recent[username][fishName]
    if last and now - last < debounceWindow then return end
    recent[username][fishName] = now
    local desc = "Username: " .. tostring(username) .. "\nFish: " .. tostring(fishName) .. "\nWeight: " .. tostring(weight)
    safePost({
        embeds = {{
            title = "🎣 Secret Fish Caught",
            description = desc,
            color = 16776960,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            footer = { text = "Fishing Monitor" }
        }}
    })
end

local function tryParseFishFromArgs(...)
    local args = {...}
    local playerName, fishName, weight
    for _, v in ipairs(args) do
        if typeof(v) == "Instance" and v:IsA("Player") then
            playerName = v.Name
        elseif type(v) == "string" then
            local lower = v:lower()
            for key, proper in pairs(fishTargets) do
                if lower:find(key) then
                    fishName = proper
                    break
                end
            end
            if not weight then
                local w = v:match("([%d%.]+)%s*kg") or v:match("weight[:%s]*([%d%.]+)") or v:match("([%d%.]+)lb")
                if w then weight = w end
            end
            if not playerName then
                local nameFrom = v:match("([%w_]+)%s+caught") or v:match("([%w_]+)%s+has caught")
                if nameFrom then playerName = nameFrom end
            end
        elseif type(v) == "number" then
            if not weight then weight = tostring(v) end
        end
    end
    return playerName, fishName, weight
end

local function scanRemotesAndConnect()
    local checked = {}
    local function tryConnect(inst)
        if checked[inst] then return end
        checked[inst] = true
        if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
            local name = inst.Name:lower()
            if name:find("fish") or name:find("caught") or name:find("catch") then
                pcall(function()
                    inst.OnClientEvent:Connect(function(...)
                        local pName, fName, wt = tryParseFishFromArgs(...)
                        if fName then
                            if not pName then pName = LocalPlayer and LocalPlayer.Name or "Unknown" end
                            if isPlayerInServer(pName) then
                                sendFishNotif(pName, fName, wt)
                            end
                        end
                    end)
                end)
            end
        end
        for _, c in ipairs(inst:GetChildren()) do
            tryConnect(c)
        end
    end
    tryConnect(game)
end

local function monitorGuiTexts()
    local function watchContainer(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton") then
                local function onChange()
                    local txt = tostring(obj.Text or "")
                    local lower = txt:lower()
                    for key, proper in pairs(fishTargets) do
                        if lower:find(key) then
                            local weight = txt:match("([%d%.]+)%s*kg") or txt:match("weight[:%s]*([%d%.]+)")
                            local username = LocalPlayer and LocalPlayer.Name or "Unknown"
                            if isPlayerInServer(username) then
                                sendFishNotif(username, proper, weight)
                            end
                        end
                    end
                end
                pcall(function() obj:GetPropertyChangedSignal("Text"):Connect(onChange) end)
                onChange()
            end
        end
    end
    local function onGuiAdded(gui)
        watchContainer(gui)
    end
    for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        pcall(watchContainer, gui)
    end
    LocalPlayer.PlayerGui.ChildAdded:Connect(onGuiAdded)
end

spawn(function()
    scanRemotesAndConnect()
    monitorGuiTexts()
    wait(2)
    for _, v in ipairs(Players:GetPlayers()) do
        recent[v.Name] = {}
    end
end)
