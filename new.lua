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
    local fountain = workspace.Interaction.UpdateItems.FairyEvent.WishFountain
    for i = 1, 3 do
        local text = fountain["Offering_" .. i].Gui.SurfaceGui.TextLabel.Text
        local name = text:match("%d+/%d+%s+Glimmering%s+(.+)")
        if name then
            offers[#offers + 1] = name
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
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and tonumber(obj.Name) then
                collectFairy(obj)
            end
        end
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
local function tryProximityPrompts(fruit)
    for _, d in ipairs(fruit:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
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
            return true
        end
    end
    return false
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
                if collectDict[plant.Name] then
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
    local lists = {...}
    local n = 0
    for i = 1, #lists do
        local list = lists[i]
        for j = 1, #list do
            n = n + 1
            merged[n] = list[j]
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
-- Các hàm Sell (Bán pet)
local function findpettosell()
    local pets = {}
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        local petname = item.Name:gsub("%s%[.-%]", "")
        if pettosellDict[petname] then
            table.insert(pets, item)
        end
    end
    return pets
end
local function updatepettosellDict()
    pettosellDict = {}
    for _, name in ipairs(pettoselllist) do
        pettosellDict[name] = true
    end
end
local function autosellpet(v)
    petselling = v
    if petselling then
        local pets = findpettosell()
        for _, pet in ipairs(pets) do
            if not pet:GetAttribute("d") then
                ReplicatedStorage.GameEvents.SellPet_RE:FireServer(pet)
                task.wait(0.2)
            end
            if not petselling then break end
        end
        petConnection = LocalPlayer.Backpack.ChildAdded:Connect(function(pet)
            if not petselling then return end
            if pet:GetAttribute("d") then return end
            local pname = pet.Name:gsub("%s%[.-%]", "")
            if not pettosellDict[pname] then return end
            task.wait(0.1)
            ReplicatedStorage.GameEvents.SellPet_RE:FireServer(pet)
        end)
    else
        if petConnection then
            petConnection:Disconnect()
            petConnection = nil
        end
    end
end
local function getmypetlist()
    local pets = {}
    local seen = {}
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        local nm = item.Name 
        if nm:find("Age") then
            nm = nm:gsub("%s%[.-%]", "")
            if not seen[nm] then
                seen[nm] = true
                table.insert(pets, nm)
            end
        end
    end
    return pets
end
-- Các hàm Misc (khác)
local function antiAFK(v)
    if v then
        if not antiAFKConnection then
            antiAFKConnection =
                LocalPlayer.Idled:Connect(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
        end
    else
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
    end
end

local function noClip(v)
    if v then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

local function clearLag(full)
    local effectClasses = {ParticleEmitter=true, Trail=true, Beam=true, Smoke=true, Fire=true, Sparkles=true}
    local textureClasses = {Decal=true, Texture=true}
    local targets = full and workspace:GetDescendants() or mainfarm:GetDescendants()
    for _, obj in ipairs(targets) do
        local className = obj.ClassName
        if effectClasses[className] then
            obj.Enabled = false
        elseif obj:IsA("BasePart") then
            obj.CastShadow = false
            obj.Material = Enum.Material.SmoothPlastic
            if not full then
                obj.Transparency = 1
                obj.CanCollide = false
            end
        elseif textureClasses[className] then
            obj.Transparency = 1
        end
    end
    if full then
        local lighting = game:GetService("Lighting")
        for _, light in ipairs(lighting:GetDescendants()) do
            if light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight") then
                light.Enabled = false
            end
        end
        local sky = lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
        for _, effect in ipairs({"BloomEffect","BlurEffect","SunRaysEffect","ColorCorrectionEffect","DepthOfFieldEffect","Atmosphere"}) do
            local e = lighting:FindFirstChildOfClass(effect)
            if e then e:Destroy() end
        end
        lighting.GlobalShadows = false
        lighting.Ambient = Color3.new(1,1,1)
        lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
end

-- Hàm hỗ trợ chung
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

-- Tạo UI
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
-- Tab Event
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
        updateCollectDict()
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
local SellTab = Window:CreateTab("Sell", 0)
local AutoSellPetToggle = SellTab:CreateToggle({
    Name = "Auto Sell Pet Selected",
    Flag = "AutoSellPetToggle",
    Callback = function(v)
        autosellpet(v)
    end
})
local PetDropdown = SellTab:CreateDropdown({
    Name = "Pet To Sell",
    Options = a(getmypetlist()),
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "PetDropdown", 
    Callback = function(v)
        pettoselllist = isall(v, getmypetlist())
        updatepettosellDict()
    end
})
local RefreshPetDropdownButton = SellTab:CreateButton({
    Name = "Refresh Pet List",
    Callback = function()
        PetDropdown:Refresh(getmypetlist())
    end
})
local CraftTab = Window:CreateTab("Craft", 0)
local MiscTab = Window:CreateTab("Misc", 0)
local AntiAFKToggle = MiscTab:CreateToggle({
    Name = "Anti AFK",
    Flag = "AntiAFKToggle",
    Callback = function(v)
        antiAFK(v)
    end
})
local NoClipToggle = MiscTab:CreateToggle({
    Name = "No Clip",
    Flag = "NoClipToggle",
    Callback = function(v)
        noClip(v)
    end
})
local RemoveEffectButton = MiscTab:CreateButton({
    Name = "Remove Effects",
    Callback = function()
        clearLag(true)
    end
})
local InvisibleFarmButton = MiscTab:CreateButton({
    Name = "Invisible Farm",
    Callback = function()
        clearLag(false)
    end
})
