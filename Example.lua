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
    Footer = "AOT:R | Keria Hub",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

_G.autoRetry = false

local function autoRetry()
    local Event = game:GetService("ReplicatedStorage").Assets.Remotes.GET
    Event:InvokeServer("Functions", "Retry", "Add")
end

local Tabs = {
    Farm = Window:AddTab("Farm", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox1 = Tabs.Farm:AddLeftGroupbox("Misc", "boxes")
LeftGroupBox1:AddButton("Return to Lobby", {
    Text = "Return to Lobby",
    Func = function()
        print("[cb] Return to Lobby clicked")
    end,
})
LeftGroupBox1:AddButton("Check Shadow Ban (Lobby)", {
    Text = "Check Shadow Ban (Lobby)",
    Func = function()
        print("[cb] Check Shadow Ban (Lobby) clicked")
    end,
})
LeftGroupBox1:AddButton("Join Discord", {
    Text = "Join Discord",
    Func = function()
        print("[cb] Join Discord clicked")
    end,
})

local AddLeftGroupBox2 = Tabs.Farm:AddLeftGroupbox("Automation", "boxes")
AddLeftGroupBox2:AddToggle("Auto Farm", {
    Text = "Auto Farm",
    Default = false,
    Callback = function(Value)
        print("[cb] Auto Farm:", Value)
    end,
})
AddLeftGroupBox2:AddToggle("Auto Farm Raids", {
    Text = "Auto Farm Raids",
    Default = false,
    Callback = function(Value)
        print("[cb] Auto Farm Raids:", Value)
    end,
})
AddLeftGroupBox2:AddToggle("Auto Retry", {
    Text = "Auto Retry",
    Default = false,
    Callback = function(Value)
        _G.autoRetry = Value
        if Value then
            autoRetry()
        end
    end,
})
AddLeftGroupBox2:AddToggle("Solo Only", {
    Text = "Solo Only",
    Default = false,
    Callback = function(Value)
        print("[cb] Solo Only:", Value)
    end,
})
AddLeftGroupBox2:AddSlider("Return to lobby after x games", {
    Text = "Return to lobby after x games",
    Default = 10,
    Min = 10,
    Max = 250,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        print("[cb] Return to lobby after x games", Value)
    end,
    Disabled = false,
    Visible = true,
})
AddLeftGroupBox2:AddToggle("Auto Start", {
    Text = "Auto Start",
    Default = false,
    Callback = function(Value)
        print("[cb] Auto Start", Value)
    end,
})
AddLeftGroupBox2:AddSlider("Start after x seconds", {
    Text = "Start after x seconds",
    Default = 0,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        print("[cb] Start after x seconds", Value)
    end,
    Disabled = false,
    Visible = true,
})

local DropdownGroupBox = Tabs.Farm:AddRightGroupbox("Dropdowns")
DropdownGroupBox:AddDropdown("MyDropdown", {
    Values = { "Hover", "Teleport" },
    Default = 1,
    Multi = false,
    Text = "Movement Mode",
    Searchable = false,
    Callback = function(Value)
        print("[cb] Dropdown got changed. New value:", Value)
    end,
    Disabled = false,
    Visible = true,
})
Options.MyDropdown:OnChanged(function()
    print("Dropdown got changed. New value:", Options.MyDropdown.Value)
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
