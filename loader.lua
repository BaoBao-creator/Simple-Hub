local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local CollectList = {}
local collecting = false
local feeding = false
local mainFarm = workspace:WaitForChild("Farm")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local flying = false
local flySpeed = 60
local flyConnection
function onfly()
    if flying then return end
    flying = true
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = humanoidRootPart
    flyConnection = RunService.RenderStepped:Connect(function()
        local camCF = workspace.CurrentCamera.CFrame
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = camCF:VectorToWorldSpace(moveDir) * flySpeed
        else
            bodyVelocity.Velocity = Vector3.zero
        end
    end)
end
function offfly()
    if not flying then return end
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if humanoidRootPart:FindFirstChild("BodyVelocity") then
        humanoidRootPart.BodyVelocity:Destroy()
    end
end
local function getMyPlantList()
    local farmsFolder = workspace.Farm
    local names, seen = {}, {}
    for _, farm in ipairs(farmsFolder:GetChildren()) do
        if farm.Important.Data.Owner.Value == LocalPlayer.Name then
            for _, plant in ipairs(farm.Important.Plants_Physical:GetChildren()) do
                if not seen[plant.Name] then
                    seen[plant.Name] = true
                    table.insert(names, plant.Name)
                end
            end
        end
    end
    return names
end
local function setFarmVisible(isVisible)
    for _, farm in ipairs(mainFarm:GetChildren()) do
        if farm:IsA("Folder") or farm:IsA("Model") then
            for _, obj in ipairs(farm:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Transparency = isVisible and 0 or 1
                    obj.CanCollide = isVisible
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = isVisible and 0 or 1
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = isVisible
                end
            end
        end
    end
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
        local farmsFolder = workspace:WaitForChild("Farm")
        while collecting do
            for _, farm in ipairs(farmsFolder:GetChildren()) do
                local imp = farm:FindFirstChild("Important")
                local data = imp and imp:FindFirstChild("Data")
                local owner = data and data:FindFirstChild("Owner")
                if owner and owner.Value == LocalPlayer.Name then
                    local plants = imp and imp:FindFirstChild("Plants_Physical")
                    if plants then
                        for _, plant in ipairs(plants:GetChildren()) do
                            if isCollectable(plant.Name) then
                                local fruitsFolder = plant:FindFirstChild("Fruits")
                                if fruitsFolder then
                                    for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                                        collectFruit(fruit)
                                        task.wait(0.25)
                                    end
                                end
                            end
                        end
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
            game:GetService("ReplicatedStorage").GameEvents.BeanstalkRESubmitAllPlant:FireServer()
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
    Name = "Tp to event shop",
    Callback = function()
        local gui = player.PlayerGui:WaitForChild("EventShop_UI")
        gui.Enabled = true
    end
})
local farmtab = window:CreateTab("Farm Tab")
farmtab:CreateDropdown({
    Name = "Plants want to collect",
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
local misctab = window:CreateTab("Misc Tab")
misctab:CreateToggle({
    Name = "Anti lag",
    Callback = function(v)
        setFarmVisible(not v)
    end
})
misctab:CreateToggle({
    Name = "Fly",
    Callback = function(v)
        if v then
            onfly()
        else
            offfly()
        end
    end
})
