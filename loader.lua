local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local CollectList = {}
local collecting = false
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
function collectall()
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
function stopcollect()
    collecting = false
end
local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()
local window = simpleui:CreateWindow({Name= "Simple Hub, BaoBao developer"})
local eventtab = window:CreateTab("Event Tab")
eventtab:CreateTextBox({
    Name = "Plants want to collect",
    Callback = function(text)
        CollectList = splitString(text, ",")
        print("CollectList set:", table.concat(CollectList, ", "))
    end
})
eventtab:CreateToggle({
    Name = "Auto Collect Nearby",
    Callback = function(v)
        if v then
            collectall()
        else
            stopcollect()
        end
    end
})
