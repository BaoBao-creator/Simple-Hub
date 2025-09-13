local ReplicatedStorage = game:GetService("ReplicatedStorage")
local function autocoin()
    ReplicatedStorage.Events.ClickMoney:FireServer()
end
