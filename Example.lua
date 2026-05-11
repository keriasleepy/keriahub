local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Keria Hub",
    Footer = "Anime Vanguards | Keria Hub",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

_G.autoStartSkip = false
_G.autoRetry = false
_G.autoNext = false
_G.autoLobby = false
_G.autoPlay = false

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local toggle = false
local function setAutoPlay(state)
    toggle = state
    _G.autoPlay = state
end

local function isStartScreenVisible()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return false end
    local screen = gui:FindFirstChild("MainGui", true)
        or gui:FindFirstChild("StartGui", true)
        or gui:FindFirstChild("WaveGui", true)
    if screen then return screen.Enabled end
    local skipEvent = RS:FindFirstChild("Networking") and RS.Networking:FindFirstChild("SkipWaveEvent")
    return skipEvent ~= nil
end

local function isEndScreenVisible()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return false end
    local endScreen = gui:FindFirstChild("EndScreen", true)
        or gui:FindFirstChild("VoteGui", true)
        or gui:FindFirstChild("ResultsGui", true)
    if endScreen then return endScreen.Enabled end
    local voteEvent = RS:FindFirstChild("Networking")
        and RS.Networking:FindFirstChild("EndScreen")
        and RS.Networking.EndScreen:FindFirstChild("VoteEvent")
    return voteEvent ~= nil
end

local function safeVote(action)
    pcall(function()
        local networking = RS:FindFirstChild("Networking")
        if not networking then return end
        local endScreen = networking:FindFirstChild("EndScreen")
        if not endScreen then return end
        local voteEvent = endScreen:FindFirstChild("VoteEvent")
        if not voteEvent then return end
        voteEvent:FireServer(action)
    end)
end

task.spawn(function()
    while true do
        task.wait(2)
        if _G.autoStartSkip and isStartScreenVisible() then
            pcall(function()
                RS.Networking.SkipWaveEvent:FireServer("Skip")
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if _G.autoRetry and isEndScreenVisible() then
            safeVote("Retry")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if _G.autoNext and isEndScreenVisible() then
            safeVote("Next")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if _G.autoLobby and isEndScreenVisible() then
            safeVote("Return to Lobby")
        end
    end
end)

local function toggleAutoPlay()
    setAutoPlay(not toggle)
    if toggle then
        task.spawn(function()
            while toggle do
                task.wait(2)
                pcall(function()
                    RS.Networking.AutoPlayEvent:FireServer("Toggle")
                end)
            end
        end)
    end
end

local Tabs = {
    Farm = Window:AddTab("Farm", "user"),
    Webhook = Window:AddTab("Webhook", "bell"),
    FPS = Window:AddTab("FPS Boost", "zap"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local AddLeftGroupBox = Tabs.Farm:AddLeftGroupbox("Auto Stuff")

AddLeftGroupBox:AddToggle("AutoStartSkip", {
    Text = "Auto Start/Skip Wave",
    Default = false,
    Callback = function(Value)
        _G.autoStartSkip = Value
    end,
})

AddLeftGroupBox:AddToggle("AutoReplay", {
    Text = "Auto Replay",
    Default = false,
    Callback = function(Value)
        _G.autoRetry = Value
    end,
})

AddLeftGroupBox:AddToggle("AutoNext", {
    Text = "Auto Next",
    Default = false,
    Callback = function(Value)
        _G.autoNext = Value
    end,
})

AddLeftGroupBox:AddToggle("AutoNextPortal", {
    Text = "Auto Next Portal",
    Default = false,
    Callback = function(Value)
        print("[cb] Auto Next Portal", Value)
    end,
})

AddLeftGroupBox:AddToggle("AutoLobby", {
    Text = "Auto Lobby",
    Default = false,
    Callback = function(Value)
        _G.autoLobby = Value
    end,
})

AddLeftGroupBox:AddToggle("AutoPlay", {
    Text = "Auto Play",
    Default = false,
    Callback = function(Value)
        toggleAutoPlay()
    end,
})

local ModeMaps = {
    ["Story"] = { "Planet Namek", "Sand Village", "Double Dungeon", "Shibuya Station", "Underground Church", "Spirit Society", "Martial Island", "Edge of Heaven", "Lebereo Raid", "Hill of Swords", "Frozen Port", "Downtown Tokyo", "Hidden Village" },
    ["Legend Stage"] = { "Sand Village", "Double Dungeon", "Shibuya Aftermath", "Golden Castle", "Kuinshi Palace", "Land of the Gods", "Shining Castle", "Crystal Chapel", "Burning Spirit Tree", "Imprisoned Island", "Tokyo Railway", "Destroyed Hidden Village" },
    ["Raid"] = { "Spider Forest", "Tracks at the Edge of the World", "Ruined City", "HAPPY Factory" },
    ["Dungeon"] = { "Ant Island", "Frozen Volcano", "Anniversary Dungeon", "Underworld" },
    ["Worldlines"] = { "Worldlines" },
    ["Odyssey"] = { "Journey", "Limitless" },
    ["World Destroyer"] = { "Prozen Port" },
    ["LTM"] = { "Eternal Tyrant Gamemode" },
}

local AddRightGroupBox = Tabs.Farm:AddRightGroupbox("Auto Join")

AddRightGroupBox:AddDropdown("ModeDropdown", {
    Values = { "Story", "Legend Stage", "Raid", "Dungeon", "Worldlines", "Odyssey", "World Destroyer", "LTM" },
    Default = 1,
    Multi = false,
    Text = "Select Mode • Story",
    Callback = function(Value)
        print("[cb] Mode changed:", Value)
    end,
})

AddRightGroupBox:AddDropdown("MapDropdown", {
    Values = ModeMaps["Story"],
    Default = 1,
    Multi = false,
    Text = "Select Map • Planet Namek",
    Callback = function(Value)
        print("[cb] Map changed:", Value)
    end,
})

AddRightGroupBox:AddDropdown("ActDropdown", {
    Values = { "Act1", "Act2", "Act3", "Act4", "Act5", "Act6", "Infinite", "Sandbox" },
    Default = 1,
    Multi = false,
    Text = "Select Act • Act1",
    Callback = function(Value)
        print("[cb] Act changed:", Value)
    end,
})

AddRightGroupBox:AddSlider("MySlider", {
    Text = "Start...",
    Default = 2,
    Min = 2,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        print("[cb] Slider:", Value)
    end,
})

AddRightGroupBox:AddDropdown("DifficultyDropdown", {
    Values = { "Normal", "Nightmare" },
    Default = 1,
    Multi = false,
    Text = "Select Difficulty",
    Callback = function(Value)
        print("[cb] Difficulty:", Value)
    end,
})

AddRightGroupBox:AddToggle("FriendsOnly", {
    Text = "Friends Only",
    Default = false,
    Callback = function(Value)
        print("[cb] Friends Only", Value)
    end,
})

AddRightGroupBox:AddToggle("AutoJoinMap", {
    Text = "Auto Join Map",
    Default = false,
    Callback = function(Value)
        print("[cb] Auto Join Map", Value)
    end,
})

AddRightGroupBox:AddToggle("AutoJoinBounty", {
    Text = "Auto Join Bounty",
    Default = false,
    Callback = function(Value)
        print("[cb] Auto Join Bounty", Value)
    end,
})

Options.ModeDropdown:OnChanged(function()
    local selectedMode = Options.ModeDropdown.Value
    local maps = ModeMaps[selectedMode] or {}
    Options.MapDropdown:SetValues(maps)
    Options.MapDropdown:SetValue(maps[1])
end)

local WebhookLeft = Tabs.Webhook:AddLeftGroupbox("Webhook")

WebhookLeft:AddInput("WebhookURL", {
    Default = "",
    Text = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
})

WebhookLeft:AddToggle("WebhookEnabled", {
    Text = "Webhook",
    Default = false,
})

local function SendWebhook(message)
    if not Toggles.WebhookEnabled.Value then return end
    local url = Options.WebhookURL.Value
    if url == "" then return end
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local payload = HttpService:JSONEncode({
            username = "Keria Hub",
            content = message,
        })
        local req = (syn and syn.request) or (http and http.request) or request
        req({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload,
        })
    end)
end

WebhookLeft:AddButton({
    Text = "Test Webhook",
    Func = function()
        local url = Options.WebhookURL.Value
        if url == "" then return end
        local HttpService = game:GetService("HttpService")
        local payload = HttpService:JSONEncode({
            username = "Keria Hub",
            embeds = {{
                title = "Anime Vanguards",
                description = "**Test Webhook**\nkeria was here 👀",
                color = 16777215,
                footer = { text = "discord.gg/25DzY3XEpJ" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })
        local req = (syn and syn.request) or (http and http.request) or request
        pcall(function()
            req({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
        end)
    end,
})

local FPSLeft = Tabs.FPS:AddLeftGroupbox("FPS Stuff")

FPSLeft:AddToggle("FPSBoost", {
    Text = "FPS Booster",
    Default = false,
    Callback = function(Value)
        settings().Rendering.QualityLevel = Value and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        settings().Rendering.MeshPartDetailLevel = Value and Enum.MeshPartDetailLevel.Level01 or Enum.MeshPartDetailLevel.Level04
        Lighting.GlobalShadows = not Value
        Lighting.FogEnd = Value and 1000000 or 100000
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("PostEffect") then v.Enabled = not Value end
        end
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = not Value
            end
        end
        local function disableChar(char)
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = not Value
                end
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then disableChar(player.Character) end
        end
        if Value then
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(char)
                    disableChar(char)
                end)
            end)
        end
    end,
})

FPSLeft:AddToggle("FPSBoost", {
    Text = "Remove Mobs",
    Default = false,
    Callback = function(Value)
        print("[cb] Friends Only", Value)
    end,
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:SetFolder("KeriaHub")
SaveManager:LoadAutoloadConfig()
