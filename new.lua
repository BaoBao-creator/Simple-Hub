-- Roblox Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local firePP = rawget(getgenv(), "fireproximityprompt") or _G.fireproximityprompt or fireproximityprompt

-- Roblox Data
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character
local humanoid = character.Humanoid
local humanoidRootPart = character.HumanoidRootPart

-- Danh sách item/shop
local collectlist, collectDict = {}, {}
local seedtobuylist, geartobuylist, eggtobuylist = {}, {}, {}
local gnomeshop = {"Common Gnome Crate", "Farmers Gnome Crate", "Classic Gnome Crate", "Iconic Gnome Crate"}
local skyshop = {"Night Staff", "Star Caller", "Mutation Spray Cloudtouched"}
local honeyshop = {"Flower Seed Pack", "Honey Sprinkler", "Bee Egg", "Bee Crate", "Honey Crafters Crate"}
local summershop = {"Cauliflower", "Rafflesia", "Green Apple", "Avocado", "Banana", "Pineapple", "Kiwi", "Bell Pepper", "Prickly Pear", "Loquat", "Feijoa", "Pitcher Plant", "Common Summer Egg", "Rare Summer Egg", "Paradise Egg"}
local sprayshop = {"Mutation Spray Wet", "Mutation Spray Windstruck", "Mutation Spray Verdant"}
local sprinklershop = {"Tropical Mist Sprinkler", "Berry Blusher Sprinkler", "Spice Spritzer Sprinkler", "Sweet Soaker Sprinkler", "Flower Froster Sprinkler", "Stalk Sprout Sprinkler"}
local gnometobuylist, skytobuylist, honeytobuylist = {}, {}, {}
local summertobuylist, spraytobuylist, sprinklertobuylist = {}, {}, {}
local pettoselllist, pettosellDict = {}, {}

-- Game Toggle
local collecting, buying, petselling, collectingFairy = false, false, false, false

-- Event connection holders
local petConnection, fairyConnection, antiAFKConnection, noclipConnection

-- Xác định khu vườn của người chơi
local mainfarm = workspace.Farm
local userfarm = nil
for _, farm in ipairs(mainfarm:GetChildren()) do
    if farm.Important.Data.Owner.Value == LocalPlayer.Name then
        userfarm = farm
        break
    end
end

-- Các hàm sự kiện
local function getoffers()
    local offers = {}
    local file = workspace.Interaction.UpdateItems.FairyEvent.WishFountain
    for i = 1, 3 do
        local offer = file["Offering_" .. i].GUI.SurfaceGui.TextLabel.Text
        if offer:find("0/1") and offer:find("Glimmering") and not offer:find("Offering") then
            local name = offer:match("%d+/%d+%s+Glimmering%s+(.+)")
            table.insert(offers, name)
        end
    end
    return offers
end

local function collectFairy(fairy)
    local prompt = fairy:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end
end

local function autoCollectFairy(v)
    collectingFairy = v
    if collectingFairy then
        -- Ban đầu collect tất cả fairy có sẵn
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and tonumber(obj.Name) then
                collectFairy(obj)
            end
        end
        -- Cài đặt sự kiện khi xuất hiện Fairy mới
        fairyConnection = workspace.ChildAdded:Connect(function(obj)
            if obj:IsA("Model") and tonumber(obj.Name) then
                local prompt = obj:WaitForChild("ProximityPrompt", 5)
                if prompt and collectingFairy then
                    fireproximityprompt(prompt)
                end
            end
        end)
    else
        if fairyConnection then
            fairyConnection:Disconnect()
            fairyConnection = nil
        end
    end
end

-- Các hàm Farm
local function updateCollectDict()
    collectDict = {}
    for _, name in ipairs(collectlist) do
        collectDict[name] = true
    end
end

local function isCollectable(plantName)
    return collectDict[plantName] == true
end

local function tryProximityPrompts(fruit)
    local ok = false
    for _, d in ipairs(fruit:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            pcall(function()
                if d.HoldDuration and d.HoldDuration > 0 then
                    d.HoldDuration = 0
                end
                if typeof(firePP) == "function" then
                    firePP(d, 1)
                else
                    d:InputHoldBegin()
                    task.wait(0.05)
                    d:InputHoldEnd()
                end
                ok = true
            end)
        end
    end
    return ok
end

local function collectFruit(fruit)
    if not fruit or not fruit.Parent then return false end
    if not (fruit:IsA("Model") or fruit:IsA("BasePart")) then return false end
    return tryProximityPrompts(fruit)
end

-- Tự động thu hoạch cây/trái
local function autocollect(v)
    collecting = v
    task.spawn(function()
        while collecting do
            local plants = userfarm.Important.Plants_Physical:GetChildren()
            for _, plant in ipairs(plants) do
                if not collecting then break end
                if isCollectable(plant.Name) then
                    local fruitsFolder = plant:FindFirstChild("Fruits")
                    if fruitsFolder then
                        local fruits = fruitsFolder:GetChildren()
                        for _, fruit in ipairs(fruits) do
                            if not collecting then break end
                            if not fruit:GetAttribute("Favorited") then
                                collectFruit(fruit)
                                task.wait(0.01)
                            end
                        end
                    else
                        if not plant:GetAttribute("Favorited") then
                            collectFruit(plant)
                            task.wait(0.01)
                        end
                    end
                end
            end
            task.wait(1.5)
        end
    end)
end

local function getmyplantlist()
    local names, seen = {}, {}
    for _, plant in ipairs(userfarm.Important.Plants_Physical:GetChildren()) do
        if not seen[plant.Name] then
            seen[plant.Name] = true
            table.insert(names, plant.Name)
        end
    end
    return names
end

-- Các hàm Shop (Mua đồ)
local function mergelists(...)
    local merged = {}
    for _, list in ipairs({...}) do
        table.move(list, 1, #list, #merged+1, merged)
    end
    return merged
end

local function getstock(shopName, itemName)
    local shop = LocalPlayer.PlayerGui[shopName].Frame.ScrollingFrame
    local item = shop:FindFirstChild(itemName)
    if item then
        local stockText = item.Main_Frame.Stock_Text.Text
        local number = string.match(stockText, "%d+")
        return tonumber(number) or 0
    end
    return 0
end

local function buy(type, name)
    if type == "seed" then
        ReplicatedStorage.GameEvents.BuySeedStock:FireServer("Tier 1", name)
    elseif type == "gear" then
        ReplicatedStorage.GameEvents.BuyGearStock:FireServer(name)
    elseif type == "egg" then
        ReplicatedStorage.GameEvents.BuyPetEgg:FireServer(name)
    elseif type == "tm" then
        ReplicatedStorage.GameEvents.BuyTravelingMerchantShopStock:FireServer(name)
    end
end

local function getitemlist(shopname)
    local names = {}
    for _, item in ipairs(LocalPlayer.PlayerGui[shopname].Frame.ScrollingFrame:GetChildren()) do
        local nm = item.Name
        if not nm:find("Padding") and not nm:find("Item_Size") and not nm:find("UIListLayout") then
            table.insert(names, nm)
        end
    end
    return names
end

local seedshop = getitemlist("Seed_Shop")
local gearshop = getitemlist("Gear_Shop")
local eggshop = getitemlist("PetShop_UI")

local function autobuy(v)
    buying = v
    task.spawn(function()
        while buying do
            local tmtobuylist = mergelists(gnometobuylist, skytobuylist, honeytobuylist, summertobuylist, spraytobuylist, sprinklertobuylist)
            for _, s in ipairs(seedtobuylist) do
                for i = 1, getstock("Seed_Shop", s) do
                    buy("seed", s)
                end
            end
            for _, g in ipairs(geartobuylist) do
                for i = 1, getstock("Gear_Shop", g) do
                    buy("gear", g)
                end
            end
            for _, e in ipairs(eggtobuylist) do
                for i = 1, getstock("PetShop_UI", e) do
                    buy("egg", e)
                end
            end
            for _, tm in ipairs(tmtobuylist) do
                for i = 1, getstock("TravelingMerchantShop_UI", tm) do
                    buy("tm", tm)
                end
            end
            task.wait(60)
        end
    end)
end
