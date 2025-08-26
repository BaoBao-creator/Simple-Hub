local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local CollectList = {}
local collecting = false
local feeding = false
local mainfarm = workspace.Farm
local userfarm
for _, farm in ipairs(mainfarm:GetChildren()) do
    if farm.Important.Data.Owner.Value == LocalPlayer.Name then
        userfarm = farm
        break
    end
end
local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()
local window = simpleui:CreateWindow({Name= "Simple Hub - Event, BaoBao developer"})
local eventtab = window:CreateTab("Event Tab")
eventtab:CreateToggle({
    Name = "Auto feed to beanstalk",
    Callback = function(v)
        if v then
            autofeed()
        else
            feeding = false
        end
    end
})
eventtab:CreateButton({
    Name = "Auto collect reward points",
    Callback = function()
        for i = 1, 20 do
            ReplicatedStorage.GameEvents.BeanstalkREClaimReward:FireServer(i)
        end
    end
})
eventtab:CreateButton({
    Name = "Open/close event shop",
    Callback = function()
        local gui = LocalPlayerp.PlayerGui:WaitForChild("EventShop_UI")
        gui.Enabled = not gui.Enabled
    end
})
