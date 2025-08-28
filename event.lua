local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local feeding = false
local buying = false
local eventshop = {"Sprout Seed Pack", "Sprout Egg", "Mandrake", "Sprout Crate", "Silver Fertilizer", "Canary Melon", "Amberheart", "Spriggan", "Skyroot Chest", "Can Of Beans", "Griffin Statue", "Bouncy Mushroom", "Glowpod", "Flare Melon", "Pet Mutation Shard Giantbean", "Gnome"}
local buylist = {}
local function autofeed()
    feeding = true
    coroutine.wrap(function()
        while feeding do
            ReplicatedStorage.GameEvents.BeanstalkRESubmitAllPlant:FireServer()
            task.wait(5)
        end  
    end)()
end
local function autobuy()
    buying = not buying
    coroutine.wrap(function()
        while buying do
            for _, name in ipairs(buylist) do
                for i = 1, 5 do
                    ReplicatedStorage.GameEvents.BuyEventShopStock:FireServer(name)
                end
            end
            task.wait(5)
        end
    end)()
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
        local gui = LocalPlayer.PlayerGui:WaitForChild("EventShop_UI")
        gui.Enabled = not gui.Enabled
    end
})
eventtab:CreateDropdown({
    Name = "Item To Buy",
    Options = {"All", table.unpack(eventshop)},
    Multi = true,
    Callback = function(v)
        if v ~= nil then
            buylist = v
            for _, i in ipairs(v) do
                if i == "All" then
                    buylist = eventshop
                end
            end   
        else
            return eventshop
        end
    end
})
eventtab:CreateToggle({
    Name = "Auto buy event shop",
    Callback = function()
        autobuy()
    end
})
eventtab:CreateButton({
    Name = "Feed To Giant",
    Callback = function()
        ReplicatedStorage.GameEvents.FeedNPC_RE:FireServer("Giant")
    end
})
