-- Roblox Data
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
-- Game List
local CollectList = {}
-- Game Toggle
local collecting = false
local feeding = false
local antiafking = false
local noclip = false
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
    for _, name in ipairs(CollectList) do
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
local function collectall()
    collecting = true
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
                            task.wait(0.1)
                        end
                    else
                        collectFruit(plant)
                        task.wait(0.1)
                    end
                end
            end
            task.wait(1.5)
        end
    end)()
end
local function getMyPlantList()
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
local function buy(type, name)
    if type == "seed" then
        ReplicatedStorage.GameEvents.BuyTravelingMerchantShopStock:FireServer("Night Staff")
        ReplicatedStorage.GameEvents.BuyPetEgg:FireServer("Common Egg")
        ReplicatedStorage.GameEvents.BuyGearStock:FireServer(item)
    end
end
local function isall(list)
    for _, i in ipairs(list) do
        if i == "all" then
            return true
        end
    end
    return false
end
local function autobuy()
    buying = true
    coroutine.wrap(function()
        while buying do
        end
    end)()
end
-- Misc Functions
local function tpui()
    local gui = LocalPlayer.PlayerGui:WaitForChild("EventShop_UI")
    gui.Enabled = not gui.Enabled
LocalPlayer.Idled:Connect(function()
    if antiafking then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)
local function setNoclip(state)
    noclip = state
end
RunService.Stepped:Connect(function()
    if noclip and humanoidRootPart then
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
-- UI
local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()
local window = simpleui:CreateWindow({Name= "Simple Hub, BaoBao developer"})
local farmtab = window:CreateTab("Farm Tab")
farmtab:CreateDropdown({
    Name = "Plants To Collect",
    Options = getMyPlantList(),
    Multi = true,
    Callback = function(v)
        if v ~= nil then
            CollectList = v
        else
            return getMyPlantList()
        end
    end
})
farmtab:CreateToggle({
    Name = "Auto Collect Nearby",
    Callback = function(v)
        if v then
            collectall()
        else
            collecting = false
        end
    end
})
local shoptap = window:CreateTab("Shop Tab")
shoptab:CreateToggle({
    Name = "Auto Buy",
    Callback = function(v)
        if v then
            autobuy()
        else
            buying = false
    end
})
local misctab = window:CreateTab("Misc Tab")
misctab:CreateToggle({
    Name = "Anti Afk",
    Callback = function(v)
        antiafking = v
    end
})
misctab:CreateToggle({
    Name = "Noclip",
    Callback = function(v)
        setNoclip(v)
    end
})
misctab:CreateButton({
    Name = "Anti Lag",
    Callback = function()
        clearlag()
    end
})
misctab:CreateButton({
    Name = "Invisible Farm",
    Callback = function()
        clearLag()
    end
})
