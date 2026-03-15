--[[
    Musical Chairs — Player Utilities
    Checks player state: sitting, locked (circling phase), close to seats.
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PlayerUtils = {}

-- How close (studs) counts as "near" a chair
PlayerUtils.CLOSE_DISTANCE = 8

function PlayerUtils.IsSitting()
    local character = Player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Sit
end

-- Detect if the player is frozen/locked (circling phase)
-- During circling the game usually anchors, sets WalkSpeed to 0, or PlatformStand
function PlayerUtils.IsPlayerLocked()
    local character = Player.Character
    if not character then return true end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return true end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    
    if hrp.Anchored then return true end
    if humanoid.WalkSpeed <= 0 then return true end
    if humanoid.PlatformStand then return true end
    
    return false
end

function PlayerUtils.IsCloseToAnySeat(GetAllSeats, GetClosestSeat)
    local character = Player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local seats = GetAllSeats()
    if #seats == 0 then return false end
    
    local _, dist = GetClosestSeat(seats, hrp.Position)
    return dist <= PlayerUtils.CLOSE_DISTANCE
end

return PlayerUtils
