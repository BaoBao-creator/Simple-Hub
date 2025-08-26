
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
        local gui = player.PlayerGui:WaitForChild("EventShop_UI")
        gui.Enabled = not gui.Enabled
    end
})
