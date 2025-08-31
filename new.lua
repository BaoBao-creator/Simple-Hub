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
local CollectList = {}
