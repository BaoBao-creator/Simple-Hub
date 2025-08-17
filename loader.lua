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
local list1 = {}
local list2 = {}
local list3 = {}
local list4 = {}
local list5 = {}
local list6 = {}
local commonseedlist = {"Carrot", "Strawberry"}
local uncommonseedlist = {"Blueberry", "Orange Tulip"}
local rareseedlist = {"Tomato", "Corn", "Daffodil"}
local legendaryseedlist = {"Watermelon", "Pumpkin", "Apple", "Bamboo"}
local mythicalseedlist = {"Coconut", "Cactus", "Dragon Fruit", "Mango"}
local divineseedlist = {"Grape", "Mushroom", "Pepper", "Cacao"}
local prismaticslist = {"Beanstalk", "Ember Lily", "Sugar Apple", "Burning Bud", "Giant Pinecone", "Elder Strawberry"}
local othergearlist = {"Trading Ticket", "Trowel", "Recall Wrench", "Cleaning Spray", "Magnifying Glass", "Favorite Tool", "Harvest Tool", "Friendship Pot"}
local plantgearlist = {"Watering Can", "Basic Sprinkler", "Advanced Sprinkler", "Godly Sprinkler", "Master Sprinkler", "Grandmaster Sprinkler"}
local petgearlist = {"Medium Toy", "Medium Treat", "Levelup Lollipop"}
local egglist = {"Common Egg", "Common Summer Egg", "Rare Summer Egg", "Mythical Egg", "Paradise Egg", "Bug Egg"}
local gnomeshop = {"Common Gnome Crate", "Farmers Gnome Crate", "Classic Gnome Crate", "Iconic Gnome Crate"}
local honeyshop = {"Flower Seed Pack", "Honey Sprinkler", "Bee Egg", "Bee Crate", "Honey Crafters Crate"}

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
end
local function buytravelingmerchant(name)
    game:GetService("ReplicatedStorage").GameEvents.BuyTravelingMerchantShopStock:FireServer(name)
end
local function getstock(shopName, itemName)
    local stockText = player.PlayerGui[shopName].Frame.ScrollingFrame[itemName].Main_Frame.Stock_Text
    local number = stockText.Text:match("X(%d+)%sStock")
    return tonumber(number) or 0
end
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
            task.wait(20)
        end
    end)()
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
shoptab:CreateDropdown({
    Name = "Seed rarity to but",
    Options = {"All", "Common", "Uncommon", "Rare", "Legendary", "Mythical", "Divine", "Prismatic"},
    Multi = false,
    Callback = function(v) 
        list1 = v
    end
})
shoptab:CreateDropdown({
    Name = "Plant Gear",
    Options = {"All", table.unpack(plantgearlist)},
    Multi = false,
    Callback = function(v) 
        list2 = v
    end
})
shoptab:CreateDropdown({
    Name = "Pet gear",
    Options = {"All", table.unpack(petgearlist)},
    Multi = false,
    Callback = function(v) 
        list3 = v
    end
})
shoptab:CreateDropdown({
    Name = "Other gear",
    Options = {"All", table.unpack(othergearlist)},
    Multi = false,
    Callback = function(v) 
        list4 = v
    end
})
shoptab:CreateDropdown({
    Name = "Honey merchant",
    Options = {"All", table.unpack(honeyshop)},
    Multi = false,
    Callback = function(v) 
        list5 = v
    end
})
shoptab:CreateDropdown({
    Name = "Gnome merchant",
    Options = {"All", table.unpack(gnomeshop)},
    Multi = false,
    Callback = function(v) 
        list6 = v
    end
})
shoptab: CreateToggle({
    Name = "Auto Buy",
    CurrentValue = false,
    Callback = function(v)
        if v then
            autobuy()
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
