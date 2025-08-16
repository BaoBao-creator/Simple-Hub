-- ======== --
-- Variables 
-- ======== --

-- Shared variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Shop variables
local buying = false
local seedlist 
local gearlist = {"Master Sprinkler", "Grandmaster Sprinkler", "Godly Sprinkler", "Medium Toy", "Medium Treat", "Levelup Lollipop", "Advanced Sprinkler", "Watering Can", "Basic Sprinkler"}
local egglist = {"Common Egg", "Common Summer Egg", "Rare Summer Egg", "Mythical Egg", "Paradise Egg", "Bug Egg"}
local amount = {1, 1, 1, 2, 2, 2, 2, 3, 3}
local travelingmerchantshop = {"Common Gnome Crate", "Farmers Gnome Crate", "Classic Gnome Crate", "Iconic Gnome Crate"}

-- ======== --
-- Functions 
-- ======== --

-- Shared functions 
local function hold(tool)
    humanoid:EquipTool(tool)
end
local function find(wl, bl, mode)
    local results = {}
    for _, item in ipairs(player.Backpack:GetChildren()) do
        local name = item.Name
        local pass = true
        for _, ww in ipairs(wl) do
            if not name:find(ww) then
                pass = false
                break
            end
        end
        if pass then
            for _, bw in ipairs(bl) do
                if name:find(bw) then
                    pass = false
                    break
                end
            end
        end
        if pass then
            if mode == "first" then
                return item
            else
                table.insert(results, item)
            end
        end
    end
    return results
end

-- Anti afk kick
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Shop functions 
local function buygear(name)
    ReplicatedStorage.GameEvents.BuyGearStock:FireServer(name)
end
local function buyseed(name)
    game:GetService("ReplicatedStorage").GameEvents.BuySeedStock:FireServer(name)
end
local function buyegg(name)
    game:GetService("ReplicatedStorage").GameEvents.BuyPetEgg:FireServer(name)
local function autobuy()
    if buying then return end
    buying = true
    coroutine.wrap(function()
        while buying do
            for idx, gear in ipairs(gearlist) do
                for j = 1, amount[idx] do
                    buy(gear)
                end
            end
            task.wait(300)
        end
    end)()
end
local function buytravelingmerchant(name)
    game:GetService("ReplicatedStorage").GameEvents.BuyTravelingMerchantShopStock:FireServer(name)
end

-- Misc functions
local function setnoclip(enabled)
    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled
        end
    end
end

-- == --
-- Ui
-- == --

local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()
local window = simpleui:CreateWindow({Name= "Simple Hub, BaoBao developer"})
local eventtab = window:CreateTab("Event Tab")
local farmtab = window:CreateTab("Farm Tab")
local shoptab = window:CreateTab("Shop Tab")
shoptab: CreateToggle({
    Name = "Auto buy good gears",
    CurrentValue = false,
    Callback = function(v)
        if v then
            buygears()
        else
            buying = false
        end
    end
})
local misctab = window:CreateTab("Misc Tab")
misctab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Callback = function(v)
        setnoclip(v)
    end
})
