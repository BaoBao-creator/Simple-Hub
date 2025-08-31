-- Roblox Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
-- Roblox Data
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character
local humanoid = character.Humanoid
local humanoidRootPart = character.HumanoidRootPart
-- Game List
local collectlist = {}
local seedtobuylist = {}
local geartobuylist = {}
local eggtobuylist = {}
local gnomeshop = {"Common Gnome Crate", "Farmers Gnome Crate", "Classic Gnome Crate", "Iconic Gnome Crate"}
local skyshop = {"Night Staff", "Star Caller", "Mutation Spray Cloudtouched"}
local honeyshop = {"Flower Seed Pack", "Honey Sprinkler", "Bee Egg", "Bee Crate", "Honey Crafters Crate"}
local summershop = {"Cauliflower", "Rafflesia", "Green Apple", "Avocado", "Banana", "Pineapple", "Kiwi", "Bell Pepper", "Prickly Pear", "Loquat", "Feijoa", "Pitcher Plant", "Common Summer Egg", "Rare Summer Egg", "Paradise Egg"}
local sprayshop = {"Mutation Spray Wet", "Mutation Spray Windstruck", "Mutation Spray Verdant"}
local sprinklershop = {"Tropical Mist Sprinkler", "Berry Blusher Sprinkler", "Spice Spritzer Sprinkler", "Sweet Soaker Sprinkler", "Flower Froster Sprinkler", "Stalk Sprout Sprinkler"}
local gnometobuylist = {}
local skytobuylist = {}
local honeytobuylist = {}
local summertobuylist = {}
local spraytobuylist = {}
local sprinklertobuylist = {}
-- Game Toggle
local collecting = false
local antiafking = false
local nocliping = false
local buying = false
-- Game Data
local mainfarm = workspace.Farm
local userfarm
for _, farm in ipairs(mainfarm:GetChildren()) do
    if farm.Important.Data.Owner.Value == LocalPlayer.Name then
        userfarm = farm
        break
    end
end
-- Farm functions
local function isCollectable(plantName)
    for _, name in ipairs(collectlist) do
        if plantName == name then
            return true
        end
    end
    return false
end
local function tryProximityPrompts(fruit)
    local ok = false
    for _, d in ipairs(fruit:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local firePP = rawget(getgenv(), "fireproximityprompt") or _G.fireproximityprompt or fireproximityprompt
            if typeof(firePP) == "function" then
                pcall(function()
                    if d.HoldDuration and d.HoldDuration > 0 then
                        d.HoldDuration = 0
                    end
                    firePP(d, 1)
                    ok = true
                end)
            else
                pcall(function()
                    d:InputHoldBegin()
                    task.wait(0.05)
                    d:InputHoldEnd()
                    ok = true
                end)
            end
        end
    end
    return ok
end
local function collectFruit(fruit)
    if not fruit or not fruit.Parent then return false end
    if not (fruit:IsA("Model") or fruit:IsA("BasePart")) then return false end
    return tryProximityPrompts(fruit)
end
local function autocollect(v)
    collecting = v
    coroutine.wrap(function()
        while collecting do
            for _, plant in ipairs(userfarm.Important.Plants_Physical:GetChildren()) do
                if not collecting then break end
                if isCollectable(plant.Name) then
                    local fruitsFolder = plant:FindFirstChild("Fruits")
                    if fruitsFolder then
                        for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                            if not collecting then break end
                            collectFruit(fruit)
                            task.wait(0.01)
                        end
                    else
                        collectFruit(plant)
                        task.wait(0.01)
                    end
                end
            end
            task.wait(1.5)
        end
    end)()
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
-- Shop Functions
local function mergelists(...)
    local merged = {}
    for _, list in ipairs({...}) do
        for _, v in ipairs(list) do
            table.insert(merged, v)
        end
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
        ReplicatedStorage.GameEvents.BuySeedStock:FireServer(name)
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
        local name = item.Name
        if not name:find("Padding") and not name:find("Item_Size") and not name:find("UIListLayout") then
            table.insert(names, name)
        end
    end
    return names
end
local seedshop = getitemlist("Seed_Shop")
local gearshop = getitemlist("Gear_Shop")
local eggshop = getitemlist("PetShop_UI")
local function autobuy(v)
    buying = v
    coroutine.wrap(function()
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
    end)()
end
-- Misc Functions
LocalPlayer.Idled:Connect(function()
    if antiafking then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)
RunService.Stepped:Connect(function()
    if nocliping and humanoidRootPart then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)
local function clearLag()
    for _, farm in ipairs(mainfarm:GetChildren()) do
        if farm:IsA("Folder") or farm:IsA("Model") then
            for _, obj in ipairs(farm:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Transparency = 1
                    obj.CanCollide = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end
        end
    end
end
local function clearlag()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") 
        or obj:IsA("Trail") 
        or obj:IsA("Beam") 
        or obj:IsA("Smoke") 
        or obj:IsA("Fire") 
        or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("BasePart") then
            obj.CastShadow = false
            obj.Material = Enum.Material.SmoothPlastic
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
    end
    for _, light in ipairs(game:GetService("Lighting"):GetDescendants()) do
        if light:IsA("PointLight") 
        or light:IsA("SpotLight") 
        or light:IsA("SurfaceLight") then
            light.Enabled = false
        end
    end
    local lighting = game:GetService("Lighting")
    local sky = lighting:FindFirstChildOfClass("Sky")
    if sky then sky:Destroy() end
    local function removeEffect(className)
        local e = lighting:FindFirstChildOfClass(className)
        if e then e:Destroy() end
    end
    removeEffect("BloomEffect")
    removeEffect("BlurEffect")
    removeEffect("SunRaysEffect")
    removeEffect("ColorCorrectionEffect")
    removeEffect("DepthOfFieldEffect")
    removeEffect("Atmosphere")
    lighting.GlobalShadows = false
    lighting.Ambient = Color3.new(1,1,1)
    lighting.OutdoorAmbient = Color3.new(1,1,1)
end
-- Shared functions 
local function a(list)
    table.insert(list, 1, "All")
    return list
end
local function isall(v, list)
    for _, i in ipairs(v) do
        if i == "All" then
            return list
        end
    end
    return v
end
-- UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Simple Hub",
    LoadingTitle = "Welcome!",
    LoadingSubtitle = "by BaoBao",
    ShowText = "Show UI",
    Theme = "Bloom",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Simple Hub Config"
    }
})
local EventTab = Window:CreateTab("Event", 0)
local FarmTab = Window:CreateTab("Farm", 0)
local AutoCollectToggle = FarmTab:CreateToggle({
    Name = "Auto Collect Plants Selected",
    Flag = "AutoCollectToggle",
    Callback = function(v)
        autocollect(v)
    end
})
local CollectDropdown = FarmTab:CreateDropdown({
    Name = "Collect List",
    Options = a(getmyplantlist()),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "CollectDropdown", 
    Callback = function(v)
        collectlist = isall(v, getmyplantlist())
    end
})
local RefreshCollectDropdownButton = FarmTab:CreateButton({
    Name = "Refresh Plant List",
    Callback = function()
        CollectDropdown:Refresh(getmyplantlist())
    end
})
local ShopTab = Window:CreateTab("Shop", 0)
local AutoBuyToggle = ShopTab:CreateToggle({
    Name = "Auto Buy Item Selected",
    Flag = "AutoBuyToggle",
    Callback = function(v)
        autobuy(v)
    end
})
local SeedDropdown = ShopTab:CreateDropdown({
    Name = "Seed Shop",
    Options = a(seedshop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "SeedDropdown", 
    Callback = function(v)
        seedtobuylist = isall(v, seedshop)
    end
})
local GearDropdown = ShopTab:CreateDropdown({
    Name = "Gear Shop",
    Options = a(gearshop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "GearDropdown", 
    Callback = function(v)
        geartobuylist = isall(v, gearshop)
    end
})
local EggDropdown = ShopTab:CreateDropdown({
    Name = "Egg Shop",
    Options = a(eggshop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "EggDropdown", 
    Callback = function(v)
        eggtobuylist = isall(v, eggshop)
    end
})
local GnomeDropdown = ShopTab:CreateDropdown({
    Name = "Gnome Shop",
    Options = a(gnomeshop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "GnomeDropdown", 
    Callback = function(v)
        gnometobuylist = isall(v, gnomeshop)
    end
})
local SkyDropdown = ShopTab:CreateDropdown({
    Name = "Sky Shop",
    Options = a(skyshop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "SkyDropdown", 
    Callback = function(v)
        skytobuylist = isall(v, skyshop)
    end
})
local HoneyDropdown = ShopTab:CreateDropdown({
    Name = "Honey Shop",
    Options = a(honeyshop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "HoneyDropdown", 
    Callback = function(v)
        honeytobuylist = isall(v, honeyshop)
    end
})
local SummerDropdown = ShopTab:CreateDropdown({
    Name = "Summer Shop",
    Options = a(summershop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "SummerDropdown", 
    Callback = function(v)
        summertobuylist = isall(v, summershop)
    end
})
local SprayDropdown = ShopTab:CreateDropdown({
    Name = "Spray Shop",
    Options = a(sprayshop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "SprayDropdown", 
    Callback = function(v)
        spraytobuylist = isall(v, sprayshop)
    end
})
local SprinklerDropdown = ShopTab:CreateDropdown({
    Name = "Sprinkler Shop",
    Options = a(sprinklershop),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "SprinklerDropdown", 
    Callback = function(v)
        sprinklertobuylist = isall(v, sprinklershop)
    end
})
local CraftTab = Window:CreateTab("Craft", 0)
local MiscTab = Window:CreateTab("Misc", 0)
local AntiAFKToggle = MiscTab:CreateToggle({
    Name = "Anti AFK",
    Flag = "AntiAFKToggle",
    Callback = function(v)
        antiafking = v
    end
})
local NoClipToggle = MiscTab:CreateToggle({
    Name = "No Clip",
    Flag = "NoClipToggle",
    Callback = function(v)
        nocliping = v
    end
})
local RemoveEffectButton = MiscTab:CreateButton({
    Name = "Remove Effects",
    Callback = function()
        clearlag()
    end
})
local InvisibleFarmButton = MiscTab:CreateButton({
    Name = "Invisible Farm",
    Callback = function()
        clearLag()
    end
})
