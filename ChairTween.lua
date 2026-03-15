--[[
    Musical Chairs — Chair Tween Module
    Two-phase movement:
      Phase 1: Tween ABOVE the closest chair (~6 studs up)
      Phase 2: Drop with gravity onto the seat
    
    Uses ScriptState.TweenSpeed for speed control.
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local ChairTween = {}
ChairTween.currentTween = nil
ChairTween.DROP_HEIGHT = 13 -- studs above the chair

-- Phase 1: Tween above the closest chair
function ChairTween.TweenAboveChair(GetAllSeats, GetClosestSeat, tweenSpeed)
    local character = Player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local seats = GetAllSeats()
    if #seats == 0 then return false end
    
    local seat, dist = GetClosestSeat(seats, hrp.Position)
    if not seat then return false end
    
    local aboveCFrame = CFrame.new(seat.Position + Vector3.new(0, ChairTween.DROP_HEIGHT, 0))
    local distToAbove = (hrp.Position - aboveCFrame.Position).Magnitude
    local tweenTime = math.clamp(distToAbove / tweenSpeed, 0.3, 4)
    
    if ChairTween.currentTween then
        ChairTween.currentTween:Cancel()
        ChairTween.currentTween = nil
    end
    
    local info = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    ChairTween.currentTween = TweenService:Create(hrp, info, {CFrame = aboveCFrame})
    ChairTween.currentTween:Play()
    ChairTween.currentTween.Completed:Wait()
    ChairTween.currentTween = nil
    return true
end

-- Phase 2: Drop onto the chair (gravity does the work)
function ChairTween.DropOntoChair()
    local character = Player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Zero velocity so we fall straight down
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    return true
end

-- Cancel any active tween
function ChairTween.Cancel()
    if ChairTween.currentTween then
        ChairTween.currentTween:Cancel()
        ChairTween.currentTween = nil
    end
end

return ChairTween
