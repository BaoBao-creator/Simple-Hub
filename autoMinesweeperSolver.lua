-- autoMinesweeperSolver.lua
-- Roblox Minesweeper Auto-Solver với inference nâng cao (subset, superset, corner, chain)

local partsfolder = workspace.Flag and workspace.Flag.Parts
if not partsfolder then
    error("Không tìm thấy folder: workspace.Flag.Parts")
end

local startX, startZ = 55, 85
local step = 5
local mapsize = 25

local function buildMap2D()
    local map = {}
    for r = 1, mapsize do
        map[r] = {}
    end

    for _, obj in ipairs(partsfolder:GetChildren()) do
        if obj:IsA("BasePart") then
            local x = math.floor(obj.Position.X)
            local z = math.floor(obj.Position.Z)
            local dx = x - startX
            local dz = z - startZ
            if dx % step == 0 and dz % step == 0 then
                local col = dx / step + 1
                local row = dz / step + 1
                if row >= 1 and row <= mapsize and col >= 1 and col <= mapsize then
                    map[row][col] = obj
                end
            end
        end
    end
    return map
end

local function neighbors(r, c)
    local n = {}
    for dr = -1, 1 do
        for dc = -1, 1 do
            if not (dr == 0 and dc == 0) then
                local rr, cc = r + dr, c + dc
                if rr >= 1 and rr <= mapsize and cc >= 1 and cc <= mapsize then
                    table.insert(n, {rr, cc})
                end
            end
        end
    end
    return n
end

local map = buildMap2D()

-- dict lưu thông tin
local numbers = {}  -- numbers["r,c"] = số
local bombs = {}    -- bombs["r,c"] = true
local safe = {}     -- safe["r,c"] = true

-- Lấy số trên TextLabel
local function getNumber(part)
    local gui = part:FindFirstChildWhichIsA("SurfaceGui")
    if gui then
        local label = gui:FindFirstChildWhichIsA("TextLabel")
        if label then
            local n = tonumber(label.Text)
            return n
        end
    end
    return nil
end

-- Khởi tạo list số
for r = 1, mapsize do
    for c = 1, mapsize do
        local p = map[r][c]
        if p then
            local n = getNumber(p)
            if n and n >= 0 then
                numbers[r .. "," .. c] = n
            end
        end
    end
end

-- Hàm đánh dấu
local function markBomb(r, c)
    bombs[r .. "," .. c] = true
end

local function markSafe(r, c)
    safe[r .. "," .. c] = true
end

-- Inference vòng lặp
local function inference()
    local changed = true
    while changed do
        changed = false

        -- Basic & subset/superset inference
        for key, num in pairs(numbers) do
            local r, c = key:match("^(%d+),(%d+)$")
            r, c = tonumber(r), tonumber(c)
            local neigh = neighbors(r, c)

            local unknown, bombcount = {}, 0
            for _, pos in ipairs(neigh) do
                local rr, cc = pos[1], pos[2]
                local k = rr .. "," .. cc
                if bombs[k] then
                    bombcount = bombcount + 1
                elseif not safe[k] then
                    table.insert(unknown, k)
                end
            end

            if #unknown > 0 then
                -- All bombs found -> còn lại safe
                if bombcount == num then
                    for _, k in ipairs(unknown) do
                        if not safe[k] then
                            safe[k] = true
                            changed = true
                        end
                    end
                -- Đủ bom trong unknown -> tất cả unknown là bom
                elseif bombcount + #unknown == num then
                    for _, k in ipairs(unknown) do
                        if not bombs[k] then
                            bombs[k] = true
                            changed = true
                        end
                    end
                end
            end
        end

        -- Pairwise subset/superset inference
        local keys = {}
        for k,_ in pairs(numbers) do table.insert(keys, k) end
        for i = 1, #keys do
            for j = i+1, #keys do
                local k1, k2 = keys[i], keys[j]
                local r1, c1 = k1:match("^(%d+),(%d+)$")
                local r2, c2 = k2:match("^(%d+),(%d+)$")
                r1, c1, r2, c2 = tonumber(r1), tonumber(c1), tonumber(r2), tonumber(c2)
                local n1, n2 = numbers[k1], numbers[k2]

                local function buildUnknown(r, c, num)
                    local neigh = neighbors(r, c)
                    local u, bombcount = {}, 0
                    for _, pos in ipairs(neigh) do
                        local rr, cc = pos[1], pos[2]
                        local kk = rr .. "," .. cc
                        if bombs[kk] then bombcount = bombcount + 1
                        elseif not safe[kk] then table.insert(u, kk) end
                    end
                    return u, num - bombcount
                end

                local u1, need1 = buildUnknown(r1, c1, n1)
                local u2, need2 = buildUnknown(r2, c2, n2)

                local set1, set2 = {}, {}
                for _,k in ipairs(u1) do set1[k] = true end
                for _,k in ipairs(u2) do set2[k] = true end

                local inter, diff12, diff21 = {}, {}, {}
                for _,k in ipairs(u1) do
                    if set2[k] then table.insert(inter, k)
                    else table.insert(diff12, k) end
                end
                for _,k in ipairs(u2) do
                    if not set1[k] then table.insert(diff21, k) end
                end

                if #inter > 0 then
                    if need1 == need2 and #diff12 > 0 and #diff21 > 0 then
                        -- Không dùng ở đây để tránh over-flag
                    elseif need1 < need2 and #diff21 > 0 then
                        for _,k in ipairs(diff21) do
                            if not bombs[k] then bombs[k] = true changed = true end
                        end
                    elseif need2 < need1 and #diff12 > 0 then
                        for _,k in ipairs(diff12) do
                            if not bombs[k] then bombs[k] = true changed = true end
                        end
                    end
                end
            end
        end

        -- Corner heuristic (chữ L)
        for key, num in pairs(numbers) do
            if num == 2 then
                local r, c = key:match("^(%d+),(%d+)$")
                r, c = tonumber(r), tonumber(c)
                local neigh = neighbors(r, c)
                local unknown = {}
                for _, pos in ipairs(neigh) do
                    local rr, cc = pos[1], pos[2]
                    local k = rr .. "," .. cc
                    if not bombs[k] and not safe[k] then
                        table.insert(unknown, {rr,cc,k})
                    end
                end
                if #unknown == 2 then
                    local dr = math.abs(unknown[1][1] - unknown[2][1])
                    local dc = math.abs(unknown[1][2] - unknown[2][2])
                    if dr == 1 and dc == 1 then
                        for _, u in ipairs(unknown) do
                            safe[u[3]] = true
                            changed = true
                        end
                    end
                end
            end
        end
    end
end

-- Run solver
inference()

print("Bombs found:", #bombs, "Safe found:", #safe)
