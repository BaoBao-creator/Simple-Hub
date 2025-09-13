local ReplicatedStorage = game:GetService("ReplicatedStorage")
local coining = false
local coindelay = 0.01
local function autocoin()
    coining = not coining
    task.spawn(function()
        while coining do
            ReplicatedStorage.Events.ClickMoney:FireServer()
            task.wait(coindelay)
        end
    end)
end
