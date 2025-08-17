-- ======== --
-- Variables 
-- ======== --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local CollectList = {}
local collecting = false
-- ======== --
-- Functions 
-- ======== --
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
                    if d.HoldDuration and d.HoldDuration > 0 then d.HoldDuration = 0 end
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
    if tryProximityPrompts(fruit) then return true end
    return false
end
function collectall()
    collecting = true
    coroutine.wrap(function()
        local farmsFolder = workspace:WaitForChild("Farm")
        for _, farm in ipairs(farmsFolder:GetChildren()) do
            local imp = farm:FindFirstChild("Important")
            local data = imp and imp:FindFirstChild("Data")
            local owner = data and data:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer.Name and then
                break
            end
        end
        while collecting do
            local plants = imp and imp:FindFirstChild("Plants_Physical")
            for _, plant in ipairs(plants:GetChildren()) do
                if isCollectable(plant.Name) then
                    local fruitsFolder = plant:FindFirstChild("Fruits")
                    if fruitsFolder then
                        for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                            collectFruit(fruit)
                        end
                    end
                end
            end
            task.wait(1.5)
        end
    end)()
end
-- == --
-- Ui
-- == --
local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()
local window = simpleui:CreateWindow({Name= "Simple Hub, BaoBao developer"})
local eventtab = window:CreateTab("Event Tab")
