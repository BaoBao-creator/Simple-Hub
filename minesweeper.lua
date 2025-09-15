local partsfolder = workspace.Flag.Parts
local partsize = 5
local mapsize = 25
local partssorted = {}
local worklabel = {}
local function updateparts()
  local worklabel = {}
	for hang = 1, mapsize do
		worklabel[hang] = {}
  end
  local partssorted = worklabel
	local minX, minZ = math.huge, math.huge
  local parts = partsfolder:GetChildren()
	for _, ph in ipairs(parts) do
		if ph:IsA("BasePart") then
			local p = ph.Position
			if p.X < minX then minX = p.X end
			if p.Z < minZ then minZ = p.Z end
		end
	end
	for _, ph in ipairs(parts) do
		if ph:IsA("BasePart") then
			local p = ph.Position
			local hang = math.floor((p.Z - minZ + 1e-4) / partsize) + 1
			local cot  = math.floor((p.X - minX + 1e-4) / partsize) + 1
			if hang >= 1 and hang <= mapsize and cot >= 1 and cot <= mapsize then
				partssorted[hang][cot] = ph
			end
			local number = ph:FindFirstChild("NumberGui")
			if number then
				text = tonumber(number.TextLabel.Text)
				if text then
					worklabel[hang][cot] = text
				else
					worklabel[hang][cot] = 0
				end
			end
		end
	end
end
