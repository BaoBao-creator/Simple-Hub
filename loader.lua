local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local player = LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local CollectList = {}
local collecting = false
local feeding = false
local mainfarm = workspace.Farm
local userfarm
local tpcollect = false
for _, farm in ipairs(mainfarm:GetChildren()) do
    if farm.Important.Data.Owner.Value == LocalPlayer.Name then
        userfarm = farm
        break
    end
end
local noclip = false
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local frozen = false
local savedWalkSpeed = humanoid.WalkSpeed
local savedJumpPower = humanoid.JumpPower
function freezePlayer()
    if not frozen then
        frozen = true
        humanoidRootPart.Anchored = true
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end
function unfreezePlayer()
    if frozen then
        frozen = false
        humanoidRootPart.Anchored = false
        humanoid.WalkSpeed = savedWalkSpeed or 16
        humanoid.JumpPower = savedJumpPower or 50
    end
end
local function checkdis(plant)
    local plantpos
    if plant.WorldPivot then
        plantpos = plant.WorldPivot.Position
    elseif plant:IsA("BasePart") and plant.Position then
        plantpos = plant.Position
    else
        return
    end
    local distance = (humanoidRootPart.Position - plantpos).Magnitude
    if distance > 15 then
        humanoidRootPart.CFrame = CFrame.new(plantpos)
    end
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
local function splitString(str, sep)
    sep = sep or ","
    local result = {}
    for token in string.gmatch(str, "([^"..sep.."]+)") do
        token = token:match("^%s*(.-)%s*$")
        table.insert(result, token)
    end
    return result
end
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
local function autofeed()
    feeding = true
    coroutine.wrap(function()
        while feeding do
            ReplicatedStorage.GameEvents.BeanstalkRESubmitAllPlant:FireServer()
            task.wait(5)
        end  
    end)()
end
local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()
local window = simpleui:CreateWindow({Name= "Simple Hub, BaoBao developer"})
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
local farmtab = window:CreateTab("Farm Tab")
farmtab:CreateDropdown({
    Name = "Plants to collect",
    Options = getMyPlantList(),
    Multi = true,
    Callback = function(v) 
        CollectList = v
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
farmtab:CreateToggle({
    Name = "Auto tp to fruits",
    Callback = function(v)
        tpcollect = v
    end
})
local misctab = window:CreateTab("Misc Tab")
misctab:CreateToggle({
    Name = "Noclip",
    Callback = function(v)
        setNoclip(v)
    end
})
misctab:CreateButton({
    Name = "Anti lag",
    Callback = function()
        clearlag()
    end
})
misctab:CreateButton({
    Name = "Very Super Mega Ultra Ultimate Anti lag",
    Callback = function()
        clearLag()
    end
})
