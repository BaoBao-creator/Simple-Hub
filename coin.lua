local ReplicatedStorage = game:GetService("ReplicatedStorage")
local coining = false
local coindelay = 0.01
local function autoclick()
    clicking = not clicking
    task.spawn(function()
        while clicking do
            ReplicatedStorage.Events.ClickMoney:FireServer()
            ReplicatedStorage.Events.ClickMoney.ClickGem:FireServer()
            task.wait(delay)
        end
    end)
end
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Simple Hub",
    LoadingTitle = "Welcome!",
    LoadingSubtitle = "by BaoBao",
    ShowText = "UI",
    Theme = "Bloom",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Simple Hub Config"
    }
})
local MainTab = Window:CreateTab("Main", 0)
MainTab:CreateToggle({
    Name = "Auto Click",
    CurrentValue = false,
    Flag = "autohealToggle",
    Callback = autoclick
})

MainTab:CreateSlider({
    Name = "Auto Click Delay",
    Range = {0.01, 0.1},
    Increment = 0.01,
    CurrentValue = 0.01,
    Flag = "DelaySlider",
    Callback = function(v)
        delay = v
    end
})
