local webhook = "https://canary.discord.com/api/webhooks/1428388916678889504/JYWapRBuVes8x6FnDn7pZHDPGpk6h76LBgVXHFfly7yiC5i_d7flkASNpaW3sc_63URs"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local request = (syn and syn.request) or (http and http.request) or request or http_request or (fluxus and fluxus.request)
if not request then
    warn("Executor kamu tidak mendukung HTTP request!")
    return
end

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

local function sendEmbed(title, desc, color, everyone)
    safeRequest({
        content = everyone and "@everyone" or nil,
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
        list ..= i .. ". " .. p.Name .. "\n"
    end
    sendEmbed("🟢 Server Monitoring", "List Player:\n" .. list .. "\nTotal player: " .. #players, 65280)
end

Players.PlayerAdded:Connect(function(player)
    sendEmbed("🔵 Player Joined", player.Name .. " has joined the server.", 65280)
end)

Players.PlayerRemoving:Connect(function(player)
    sendEmbed("🔴 Player Disconnected", player.Name .. " has left the server.", 16711680)
end)

task.spawn(function()
    sendPlayerList()
    while task.wait(600) do
        sendPlayerList()
    end
end)

local secretFishes = {
    ["elshark gran maja"] = true,
    ["robot kraken"] = true,
    ["bone whale"] = true,
    ["crystal crab"] = true,
    ["orca"] = true,
    ["blob shark"] = true,
    ["ghost shark"] = true,
    ["worm fish"] = true,
    ["lochnes monster"] = true,
    ["eerie shark"] = true,
    ["monster shark"] = true,
    ["thin armor shark"] = true,
    ["great whale"] = true,
    ["frostborn shark"] = true,
    ["queen crab"] = true,
    ["king crab"] = true,
    ["panther eel"] = true,
    ["giant squid"] = true,
    ["ghost worm fish"] = true,
    ["megalodon"] = true,
    ["king jelly"] = true,
    ["mosasaurus shark"] = true
}

local debounce = {}
local debounceDelay = 8

local function sendFishNotif(username, fishName, weight)
    local now = os.time()
    debounce[username] = debounce[username] or {}
    if debounce[username][fishName] and now - debounce[username][fishName] < debounceDelay then return end
    debounce[username][fishName] = now
    local desc = string.format("Username: %s\nFish: %s\nWeight: %s Kg", username, fishName, weight or "Unknown")
    sendEmbed("🎣 Secret Fish Caught", desc, 16776960, true)
end

local function onChatMessage(msg)
    local text = msg.Text or msg
    text = text:gsub("%s+", " "):lower()
    local username, fish, weight = text:match("%[server%]%s*[:%-]%s*([%w_]+)%s+[%w%s]*%s+([%a%s]+)%s*%(([%d%.]+)%s*kg%)")
    if username and fish then
        fish = fish:gsub("^%s*(.-)%s*$", "%1")
        if secretFishes[fish:lower()] then
            sendFishNotif(username, fish, weight)
        end
    end
end

task.spawn(function()
    local function hookChannel(channel)
        channel.MessageReceived:Connect(onChatMessage)
    end
    for _, ch in ipairs(TextChatService:GetChildren()) do
        if ch:IsA("TextChannel") then
            hookChannel(ch)
        end
    end
    TextChatService.ChildAdded:Connect(function(ch)
        if ch:IsA("TextChannel") then
            hookChannel(ch)
        end
    end)
end)

for _, v in ipairs(Players:GetPlayers()) do
    debounce[v.Name] = {}
end
