local ReplicatedStorage = game:GetService("ReplicatedStorage")
local coining = false
local coindelay = 0.01
local function autocoin()
    coining = not coining
    task.spawn(function()
        while coining do
            ReplicatedStorage.Events.ClickMoney:FireServer()
            task.wait(coindelay)
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
    Name = "Auto Coin",
    CurrentValue = false,
    Flag = "autohealToggle",
    Callback = autocoin
})

MainTab:CreateSlider({
    Name = "Auto Coin Delay",
    Range = {0.01, 0.1},
    Increment = 0.01,
    CurrentValue = 0.01,
    Flag = "DelaySlider",
    Callback = function(v)
        coindelay = v
    end
})
