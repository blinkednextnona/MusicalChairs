--[[
    ╔═══════════════════════════════════════════════╗
    ║         MUSICAL CHAIRS SCRIPT                 ║
    ║            Made By CozzyBruh                  ║
    ╚═══════════════════════════════════════════════╝
    
    Features:
    • Auto TP to chairs when toggled on
    • Adjustable tween speed (how fast you glide to chairs)
    • Anti-AFK built in
    • Draggable window with smooth tweening
    • Close / minimize with animations
    • Tab system with indicator bar
    • Toggle switches, buttons, sliders
    • Notification system
    • Keybind to toggle UI (RightShift)
]]

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════════
-- SCRIPT STATE
-- ═══════════════════════════════════════
local ScriptState = {
    AutoChair = false,
    AntiAFK = true,
    TweenSpeed = 50, -- studs per second (default: natural jog speed)
}

-- ═══════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════
local CONFIG = {
    -- Main Colors
    Background        = Color3.fromRGB(15, 15, 20),
    BackgroundSecond  = Color3.fromRGB(20, 20, 28),
    Surface           = Color3.fromRGB(25, 25, 35),
    SurfaceHover      = Color3.fromRGB(32, 32, 45),
    Border            = Color3.fromRGB(40, 40, 55),
    
    -- Accent
    Accent            = Color3.fromRGB(88, 101, 242),
    AccentHover       = Color3.fromRGB(108, 121, 255),
    AccentDim         = Color3.fromRGB(88, 101, 242),
    
    -- Text
    TextPrimary       = Color3.fromRGB(235, 235, 245),
    TextSecondary     = Color3.fromRGB(145, 145, 165),
    TextMuted         = Color3.fromRGB(90, 90, 110),
    
    -- Semantic
    Success           = Color3.fromRGB(72, 199, 142),
    Warning           = Color3.fromRGB(250, 176, 67),
    Error             = Color3.fromRGB(237, 95, 95),
    
    -- Layout
    WindowWidth       = 520,
    WindowHeight      = 380,
    CornerRadius      = UDim.new(0, 10),
    SmallRadius       = UDim.new(0, 6),
    
    -- Animation
    TweenSpeed        = 0.3,
    TweenEase         = Enum.EasingStyle.Quint,
    
    -- Font
    Font              = Enum.Font.GothamBold,
    FontMedium        = Enum.Font.GothamMedium,
    FontRegular       = Enum.Font.Gotham,
    
    -- Settings
    ToggleKey         = Enum.KeyCode.RightShift,
    Title             = "Musical Chairs",
    Subtitle          = "Made By CozzyBruh",
}

-- ═══════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════
local function Tween(object, props, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or CONFIG.TweenSpeed,
        style or CONFIG.TweenEase,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, props)
    tween:Play()
    return tween
end

local function CreateInstance(className, properties, children)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function AddCorner(parent, radius)
    return CreateInstance("UICorner", {
        CornerRadius = radius or CONFIG.CornerRadius,
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return CreateInstance("UIStroke", {
        Color = color or CONFIG.Border,
        Thickness = thickness or 1,
        Transparency = 0.5,
        Parent = parent
    })
end

local function AddPadding(parent, t, b, l, r)
    return CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, t or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft = UDim.new(0, l or 8),
        PaddingRight = UDim.new(0, r or 8),
        Parent = parent
    })
end

-- ═══════════════════════════════════════
-- CHAIR FINDER UTILITY
-- ═══════════════════════════════════════
local CLOSE_DISTANCE = 8 -- studs; if closer than this to any seat, stop TPing

local function GetAllSeats()
    local seats = {}
    
    -- There are MULTIPLE things named "Chairs" in workspace.
    -- We need the one that actually contains "Chair" models inside it.
    local chairsFolder = nil
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Chairs" then
            -- Check if this one has children named "Chair" inside
            local hasChairChild = false
            for _, child in pairs(obj:GetChildren()) do
                if child.Name == "Chair" then
                    hasChairChild = true
                    break
                end
            end
            if hasChairChild then
                chairsFolder = obj
                break
            end
        end
    end
    
    -- If we still didn't find it, try any "Chairs" that has ANY descendants
    if not chairsFolder then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == "Chairs" and #obj:GetChildren() > 0 then
                chairsFolder = obj
                break
            end
        end
    end
    
    if not chairsFolder then return seats end
    
    -- First priority: find Seat / VehicleSeat instances (the actual sit parts)
    for _, desc in pairs(chairsFolder:GetDescendants()) do
        if desc:IsA("Seat") or desc:IsA("VehicleSeat") then
            table.insert(seats, desc)
        end
    end
    
    -- Second: grab a BasePart from each Chair model
    if #seats == 0 then
        for _, child in pairs(chairsFolder:GetChildren()) do
            if child:IsA("Model") then
                -- Get primary part or first BasePart
                local part = child.PrimaryPart
                if not part then
                    for _, p in pairs(child:GetDescendants()) do
                        if p:IsA("BasePart") then
                            part = p
                            break
                        end
                    end
                end
                if part then
                    table.insert(seats, part)
                end
            elseif child:IsA("BasePart") then
                table.insert(seats, child)
            end
        end
    end
    
    -- Last resort: any BasePart descendant at all
    if #seats == 0 then
        for _, desc in pairs(chairsFolder:GetDescendants()) do
            if desc:IsA("BasePart") then
                table.insert(seats, desc)
            end
        end
    end
    
    return seats
end

local function GetClosestSeat(seats, position)
    local closest = nil
    local closestDist = math.huge
    for _, seat in pairs(seats) do
        local dist = (seat.Position - position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = seat
        end
    end
    return closest, closestDist
end

local currentTween = nil

-- Detect if the player is frozen/locked (circling phase)
-- During circling the humanoid usually can't jump or walkspeed is 0 or anchored
local function IsPlayerLocked()
    local character = Player.Character
    if not character then return true end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return true end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    
    -- If anchored, we're locked
    if hrp.Anchored then return true end
    
    -- If walkspeed is 0, we're in the circling phase
    if humanoid.WalkSpeed <= 0 then return true end
    
    -- If PlatformStand is on, we're locked
    if humanoid.PlatformStand then return true end
    
    return false
end

local currentTween = nil
local DROP_HEIGHT = 13 -- studs above the chair to hover before dropping

-- Step 1: Tween ABOVE the closest chair (hovers ~6 studs over it)
local function TweenAboveChair()
    local character = Player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local seats = GetAllSeats()
    if #seats == 0 then return false end
    
    local seat, dist = GetClosestSeat(seats, hrp.Position)
    if not seat then return false end
    
    -- Target: directly above the chair
    local aboveCFrame = CFrame.new(seat.Position + Vector3.new(0, DROP_HEIGHT, 0))
    
    local distToAbove = (hrp.Position - aboveCFrame.Position).Magnitude
    local tweenTime = math.clamp(distToAbove / ScriptState.TweenSpeed, 0.3, 4)
    
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    
    local info = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    currentTween = TweenService:Create(hrp, info, {CFrame = aboveCFrame})
    currentTween:Play()
    currentTween.Completed:Wait()
    currentTween = nil
    return true
end

-- Step 2: Just drop the player — let gravity do the work
local function DropOntoChair()
    -- Nothing to tween — just make sure velocity is zero so we fall straight down
    local character = Player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Kill any horizontal velocity so we drop straight
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    
    return true
end

local function IsCloseToAnySeat()
    local character = Player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local seats = GetAllSeats()
    if #seats == 0 then return false end
    
    local _, dist = GetClosestSeat(seats, hrp.Position)
    return dist <= CLOSE_DISTANCE
end

local function IsSitting()
    local character = Player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Sit
end

-- ═══════════════════════════════════════
-- AUTO CHAIR LOOP — STATE MACHINE
-- Phase 1: tween ABOVE a chair
-- Phase 2 (next iteration): drop onto it
-- Then wait until next round
-- ═══════════════════════════════════════
local autoChairThread = nil

local function StartAutoChair()
    if autoChairThread then return end
    
    autoChairThread = task.spawn(function()
        local phase = 1 -- 1 = fly above, 2 = drop
        
        while ScriptState.AutoChair do
            if IsSitting() then
                phase = 1
                task.wait(0.5)
            elseif IsPlayerLocked() then
                phase = 1
                task.wait(0.2)
            elseif phase == 1 then
                local success = TweenAboveChair()
                if success and not IsSitting() then
                    phase = 2
                    task.wait(0.1)
                else
                    task.wait(0.3)
                end
            elseif phase == 2 then
                DropOntoChair()
                phase = 1
                task.wait(0.5)
            end
        end
        autoChairThread = nil
    end)
end

local function StopAutoChair()
    ScriptState.AutoChair = false
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    autoChairThread = nil
end

-- ═══════════════════════════════════════
-- ANTI-AFK SYSTEM
-- ═══════════════════════════════════════
local antiAfkConnection = nil

local function StartAntiAFK()
    if antiAfkConnection then return end
    
    -- Method 1: VirtualUser (most reliable on most executors)
    antiAfkConnection = Player.Idled:Connect(function()
        if ScriptState.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end)
end

local function StopAntiAFK()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
end

-- Start anti-AFK immediately
ScriptState.AntiAFK = true
StartAntiAFK()

-- ═══════════════════════════════════════
-- CORE GUI
-- ═══════════════════════════════════════
local ScreenGui = CreateInstance("ScreenGui", {
    Name = "MusicalChairsUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = Player:WaitForChild("PlayerGui")
})

-- Shadow behind the main window
local Shadow = CreateInstance("ImageLabel", {
    Name = "Shadow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, CONFIG.WindowWidth + 40, 0, CONFIG.WindowHeight + 40),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.4,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
    Parent = ScreenGui
})

-- Main Window Frame
local MainFrame = CreateInstance("Frame", {
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight),
    BackgroundColor3 = CONFIG.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = ScreenGui
})
AddCorner(MainFrame)
AddStroke(MainFrame, CONFIG.Border, 1)

-- ═══════════════════════════════════════
-- DRAGGING SYSTEM
-- ═══════════════════════════════════════
local Dragging, DragInput, DragStart, StartPos

local function DragUpdate(input)
    local delta = input.Position - DragStart
    local targetPos = UDim2.new(
        StartPos.X.Scale, StartPos.X.Offset + delta.X,
        StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
    )
    Tween(MainFrame, {Position = targetPos}, 0.08, Enum.EasingStyle.Quart)
    Shadow.Position = targetPos
end

-- ═══════════════════════════════════════
-- TOP BAR
-- ═══════════════════════════════════════
local TopBar = CreateInstance("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = CONFIG.Background,
    BorderSizePixel = 0,
    Parent = MainFrame
})

-- Accent line at very top
CreateInstance("Frame", {
    Name = "AccentLine",
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = CONFIG.Accent,
    BorderSizePixel = 0,
    Parent = TopBar
})

-- Title
local TitleLabel = CreateInstance("TextLabel", {
    Name = "Title",
    Position = UDim2.new(0, 16, 0, 2),
    Size = UDim2.new(0, 200, 1, -2),
    BackgroundTransparency = 1,
    Text = CONFIG.Title,
    TextColor3 = CONFIG.TextPrimary,
    TextSize = 14,
    Font = CONFIG.Font,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar
})

-- Subtitle
CreateInstance("TextLabel", {
    Name = "Subtitle",
    Position = UDim2.new(0, 136, 0, 2),
    Size = UDim2.new(0, 130, 1, -2),
    BackgroundTransparency = 1,
    Text = CONFIG.Subtitle,
    TextColor3 = CONFIG.TextMuted,
    TextSize = 11,
    Font = CONFIG.FontRegular,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar
})

-- Close Button
local CloseBtn = CreateInstance("TextButton", {
    Name = "CloseBtn",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 1),
    Size = UDim2.new(0, 28, 0, 28),
    BackgroundColor3 = CONFIG.Surface,
    BackgroundTransparency = 1,
    Text = "✕",
    TextColor3 = CONFIG.TextSecondary,
    TextSize = 14,
    Font = CONFIG.Font,
    Parent = TopBar
})
AddCorner(CloseBtn, CONFIG.SmallRadius)

-- Minimize Button
local MinBtn = CreateInstance("TextButton", {
    Name = "MinBtn",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -42, 0.5, 1),
    Size = UDim2.new(0, 28, 0, 28),
    BackgroundColor3 = CONFIG.Surface,
    BackgroundTransparency = 1,
    Text = "─",
    TextColor3 = CONFIG.TextSecondary,
    TextSize = 14,
    Font = CONFIG.Font,
    Parent = TopBar
})
AddCorner(MinBtn, CONFIG.SmallRadius)

-- Button hover effects
for _, btn in pairs({CloseBtn, MinBtn}) do
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundTransparency = 0.5, TextColor3 = CONFIG.TextPrimary}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundTransparency = 1, TextColor3 = CONFIG.TextSecondary}, 0.15)
    end)
end

-- Drag from TopBar
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        DragUpdate(input)
    end
end)

-- ═══════════════════════════════════════
-- DIVIDER UNDER TOPBAR
-- ═══════════════════════════════════════
CreateInstance("Frame", {
    Name = "Divider",
    Position = UDim2.new(0, 0, 0, 44),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = CONFIG.Border,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Parent = MainFrame
})

-- ═══════════════════════════════════════
-- TAB SIDEBAR
-- ═══════════════════════════════════════
local Sidebar = CreateInstance("Frame", {
    Name = "Sidebar",
    Position = UDim2.new(0, 0, 0, 45),
    Size = UDim2.new(0, 130, 1, -45),
    BackgroundColor3 = CONFIG.BackgroundSecond,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = MainFrame
})

-- Sidebar right border (parented to MainFrame, NOT sidebar, so it doesn't mess with layout)
CreateInstance("Frame", {
    Name = "SidebarBorder",
    Position = UDim2.new(0, 130, 0, 45),
    Size = UDim2.new(0, 1, 1, -45),
    BackgroundColor3 = CONFIG.Border,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Parent = MainFrame
})

-- Tab container inside sidebar (this is what gets the list layout)
local TabContainer = CreateInstance("Frame", {
    Name = "TabContainer",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Parent = Sidebar
})

CreateInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2),
    Parent = TabContainer
})

AddPadding(TabContainer, 8, 8, 6, 6)

-- ═══════════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════════
local ContentArea = CreateInstance("Frame", {
    Name = "ContentArea",
    Position = UDim2.new(0, 131, 0, 45),
    Size = UDim2.new(1, -131, 1, -45),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = MainFrame
})

-- ═══════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════
local NotifHolder = CreateInstance("Frame", {
    Name = "Notifications",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.new(0, 250, 0, 300),
    BackgroundTransparency = 1,
    Parent = ScreenGui
})

CreateInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Parent = NotifHolder
})

local function Notify(title, message, duration, notifType)
    local accentColor = CONFIG.Accent
    if notifType == "success" then accentColor = CONFIG.Success
    elseif notifType == "warning" then accentColor = CONFIG.Warning
    elseif notifType == "error" then accentColor = CONFIG.Error
    end
    
    local Notif = CreateInstance("Frame", {
        Size = UDim2.new(0, 250, 0, 0),
        BackgroundColor3 = CONFIG.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifHolder
    })
    AddCorner(Notif, CONFIG.SmallRadius)
    AddStroke(Notif, CONFIG.Border, 1)
    
    CreateInstance("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = Notif
    })
    
    CreateInstance("TextLabel", {
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -24, 0, 16),
        BackgroundTransparency = 1,
        Text = title or "Notification",
        TextColor3 = CONFIG.TextPrimary,
        TextSize = 12,
        Font = CONFIG.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notif
    })
    
    CreateInstance("TextLabel", {
        Position = UDim2.new(0, 14, 0, 28),
        Size = UDim2.new(1, -24, 0, 28),
        BackgroundTransparency = 1,
        Text = message or "",
        TextColor3 = CONFIG.TextSecondary,
        TextSize = 11,
        Font = CONFIG.FontRegular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = Notif
    })
    
    Tween(Notif, {Size = UDim2.new(0, 250, 0, 64)}, 0.35)
    
    task.delay(duration or 3, function()
        Tween(Notif, {Size = UDim2.new(0, 250, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.wait(0.35)
        Notif:Destroy()
    end)
end

-- ═══════════════════════════════════════
-- LIBRARY API
-- ═══════════════════════════════════════
local Library = {}
Library.__index = Library

local Tabs = {}
local ActiveTab = nil
local TabButtons = {}
local TabPages = {}

local function SelectTab(index)
    if ActiveTab == index then return end
    
    if ActiveTab then
        local oldBtn = TabButtons[ActiveTab]
        local oldPage = TabPages[ActiveTab]
        if oldBtn then
            Tween(oldBtn, {BackgroundTransparency = 1}, 0.2)
            local oldIcon = oldBtn:FindFirstChild("TabIcon")
            local oldName = oldBtn:FindFirstChild("TabName")
            local oldIndicator = oldBtn:FindFirstChild("ActiveIndicator")
            if oldIcon then Tween(oldIcon, {TextColor3 = CONFIG.TextMuted}, 0.2) end
            if oldName then Tween(oldName, {TextColor3 = CONFIG.TextSecondary}, 0.2) end
            if oldIndicator then Tween(oldIndicator, {BackgroundTransparency = 1}, 0.15) end
        end
        if oldPage then oldPage.Visible = false end
    end
    
    ActiveTab = index
    local newBtn = TabButtons[index]
    local newPage = TabPages[index]
    if newBtn then
        Tween(newBtn, {BackgroundTransparency = 0.85}, 0.2)
        local newIcon = newBtn:FindFirstChild("TabIcon")
        local newName = newBtn:FindFirstChild("TabName")
        local newIndicator = newBtn:FindFirstChild("ActiveIndicator")
        if newIcon then Tween(newIcon, {TextColor3 = CONFIG.TextPrimary}, 0.2) end
        if newName then Tween(newName, {TextColor3 = CONFIG.TextPrimary}, 0.2) end
        if newIndicator then Tween(newIndicator, {BackgroundTransparency = 0}, 0.2) end
    end
    if newPage then newPage.Visible = true end
end

function Library:AddTab(name, icon)
    local tabIndex = #Tabs + 1
    
    local TabBtn = CreateInstance("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        LayoutOrder = tabIndex,
        Parent = TabContainer
    })
    AddCorner(TabBtn, CONFIG.SmallRadius)
    
    local ActiveIndicator = CreateInstance("Frame", {
        Name = "ActiveIndicator",
        Size = UDim2.new(0, 3, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = TabBtn
    })
    AddCorner(ActiveIndicator, UDim.new(1, 0))
    
    CreateInstance("TextLabel", {
        Name = "TabIcon",
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1,
        Text = icon or "•",
        TextColor3 = CONFIG.TextMuted,
        TextSize = 14,
        Font = CONFIG.FontRegular,
        Parent = TabBtn
    })
    
    CreateInstance("TextLabel", {
        Name = "TabName",
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = CONFIG.TextSecondary,
        TextSize = 12,
        Font = CONFIG.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TabBtn
    })
    
    local TabPage = CreateInstance("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = CONFIG.Accent,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = ContentArea
    })
    
    CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = TabPage
    })
    
    AddPadding(TabPage, 10, 10, 14, 14)
    
    TabButtons[tabIndex] = TabBtn
    TabPages[tabIndex] = TabPage
    table.insert(Tabs, name)
    
    TabBtn.MouseEnter:Connect(function()
        if ActiveTab ~= tabIndex then
            Tween(TabBtn, {BackgroundTransparency = 0.88}, 0.15)
            local tn = TabBtn:FindFirstChild("TabName")
            local ti = TabBtn:FindFirstChild("TabIcon")
            if tn then Tween(tn, {TextColor3 = CONFIG.TextPrimary}, 0.15) end
            if ti then Tween(ti, {TextColor3 = CONFIG.TextSecondary}, 0.15) end
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if ActiveTab ~= tabIndex then
            Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
            local tn = TabBtn:FindFirstChild("TabName")
            local ti = TabBtn:FindFirstChild("TabIcon")
            if tn then Tween(tn, {TextColor3 = CONFIG.TextSecondary}, 0.15) end
            if ti then Tween(ti, {TextColor3 = CONFIG.TextMuted}, 0.15) end
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        SelectTab(tabIndex)
    end)
    
    if tabIndex == 1 then
        SelectTab(1)
    end
    
    local Tab = {}
    Tab.Page = TabPage
    
    function Tab:AddSection(text)
        return CreateInstance("TextLabel", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Text = string.upper(text),
            TextColor3 = CONFIG.TextMuted,
            TextSize = 10,
            Font = CONFIG.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = #TabPage:GetChildren(),
            Parent = TabPage
        })
    end
    
    function Tab:AddToggle(text, default, callback)
        callback = callback or function() end
        local toggled = default or false
        
        local ToggleFrame = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = CONFIG.Surface,
            BorderSizePixel = 0,
            LayoutOrder = #TabPage:GetChildren(),
            Parent = TabPage
        })
        AddCorner(ToggleFrame, CONFIG.SmallRadius)
        
        CreateInstance("TextLabel", {
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = CONFIG.TextPrimary,
            TextSize = 12,
            Font = CONFIG.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ToggleFrame
        })
        
        local SwitchTrack = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0, 36, 0, 20),
            BackgroundColor3 = toggled and CONFIG.Accent or CONFIG.Border,
            BorderSizePixel = 0,
            Parent = ToggleFrame
        })
        AddCorner(SwitchTrack, UDim.new(1, 0))
        
        local SwitchKnob = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundColor3 = CONFIG.TextPrimary,
            BorderSizePixel = 0,
            Parent = SwitchTrack
        })
        AddCorner(SwitchKnob, UDim.new(1, 0))
        
        local ClickBtn = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = ToggleFrame
        })
        
        ClickBtn.MouseEnter:Connect(function()
            Tween(ToggleFrame, {BackgroundColor3 = CONFIG.SurfaceHover}, 0.15)
        end)
        ClickBtn.MouseLeave:Connect(function()
            Tween(ToggleFrame, {BackgroundColor3 = CONFIG.Surface}, 0.15)
        end)
        
        ClickBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            Tween(SwitchTrack, {BackgroundColor3 = toggled and CONFIG.Accent or CONFIG.Border}, 0.2)
            Tween(SwitchKnob, {Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2)
            callback(toggled)
        end)
        
        return ToggleFrame
    end
    
    function Tab:AddButton(text, callback)
        callback = callback or function() end
        
        local Button = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = CONFIG.Surface,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = CONFIG.TextPrimary,
            TextSize = 12,
            Font = CONFIG.FontMedium,
            LayoutOrder = #TabPage:GetChildren(),
            Parent = TabPage
        })
        AddCorner(Button, CONFIG.SmallRadius)
        
        Button.MouseEnter:Connect(function()
            Tween(Button, {BackgroundColor3 = CONFIG.SurfaceHover}, 0.15)
        end)
        Button.MouseLeave:Connect(function()
            Tween(Button, {BackgroundColor3 = CONFIG.Surface}, 0.15)
        end)
        Button.MouseButton1Click:Connect(function()
            Tween(Button, {BackgroundColor3 = CONFIG.Accent}, 0.1)
            task.wait(0.12)
            Tween(Button, {BackgroundColor3 = CONFIG.Surface}, 0.2)
            callback()
        end)
        
        return Button
    end
    
    function Tab:AddAccentButton(text, callback)
        callback = callback or function() end
        
        local Button = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = CONFIG.Accent,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            Font = CONFIG.Font,
            LayoutOrder = #TabPage:GetChildren(),
            Parent = TabPage
        })
        AddCorner(Button, CONFIG.SmallRadius)
        
        Button.MouseEnter:Connect(function()
            Tween(Button, {BackgroundColor3 = CONFIG.AccentHover}, 0.15)
        end)
        Button.MouseLeave:Connect(function()
            Tween(Button, {BackgroundColor3 = CONFIG.Accent}, 0.15)
        end)
        Button.MouseButton1Click:Connect(function()
            callback()
        end)
        
        return Button
    end
    
    function Tab:AddSlider(text, min, max, default, callback)
        callback = callback or function() end
        min = min or 0
        max = max or 100
        default = default or min
        
        local SliderFrame = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = CONFIG.Surface,
            BorderSizePixel = 0,
            LayoutOrder = #TabPage:GetChildren(),
            Parent = TabPage
        })
        AddCorner(SliderFrame, CONFIG.SmallRadius)
        
        CreateInstance("TextLabel", {
            Position = UDim2.new(0, 12, 0, 6),
            Size = UDim2.new(1, -60, 0, 18),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = CONFIG.TextPrimary,
            TextSize = 12,
            Font = CONFIG.FontMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = SliderFrame
        })
        
        local ValueLabel = CreateInstance("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -12, 0, 6),
            Size = UDim2.new(0, 40, 0, 18),
            BackgroundTransparency = 1,
            Text = tostring(default),
            TextColor3 = CONFIG.Accent,
            TextSize = 12,
            Font = CONFIG.Font,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = SliderFrame
        })
        
        local Track = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 32),
            Size = UDim2.new(1, -24, 0, 4),
            BackgroundColor3 = CONFIG.Border,
            BorderSizePixel = 0,
            Parent = SliderFrame
        })
        AddCorner(Track, UDim.new(1, 0))
        
        local Fill = CreateInstance("Frame", {
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = CONFIG.Accent,
            BorderSizePixel = 0,
            Parent = Track
        })
        AddCorner(Fill, UDim.new(1, 0))
        
        local Knob = CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundColor3 = CONFIG.TextPrimary,
            BorderSizePixel = 0,
            Parent = Track
        })
        AddCorner(Knob, UDim.new(1, 0))
        
        local sliding = false
        
        local SliderBtn = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = SliderFrame
        })
        
        local function updateSlider(input)
            local trackAbsPos = Track.AbsolutePosition.X
            local trackAbsSize = Track.AbsoluteSize.X
            local relative = math.clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
            local value = math.floor(min + (max - min) * relative)
            
            Tween(Fill, {Size = UDim2.new(relative, 0, 1, 0)}, 0.08)
            Tween(Knob, {Position = UDim2.new(relative, 0, 0.5, 0)}, 0.08)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
        
        SliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                updateSlider(input)
            end
        end)
        
        SliderBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        SliderBtn.MouseEnter:Connect(function()
            Tween(SliderFrame, {BackgroundColor3 = CONFIG.SurfaceHover}, 0.15)
        end)
        SliderBtn.MouseLeave:Connect(function()
            Tween(SliderFrame, {BackgroundColor3 = CONFIG.Surface}, 0.15)
        end)
        
        return SliderFrame
    end
    
    function Tab:AddLabel(text)
        return CreateInstance("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = CONFIG.TextSecondary,
            TextSize = 11,
            Font = CONFIG.FontRegular,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = #TabPage:GetChildren(),
            Parent = TabPage
        })
    end
    
    function Tab:AddSeparator()
        local Sep = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 8),
            BackgroundTransparency = 1,
            LayoutOrder = #TabPage:GetChildren(),
            Parent = TabPage
        })
        CreateInstance("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = CONFIG.Border,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = Sep
        })
        return Sep
    end
    
    return Tab
end

function Library:SelectTab(index)
    SelectTab(index)
end

-- ═══════════════════════════════════════
-- OPEN / CLOSE ANIMATIONS
-- ═══════════════════════════════════════
local isOpen = true

local function CloseUI()
    isOpen = false
    Tween(MainFrame, {Size = UDim2.new(0, CONFIG.WindowWidth, 0, 0)}, 0.35)
    Tween(Shadow, {ImageTransparency = 1}, 0.3)
    task.wait(0.35)
    MainFrame.Visible = false
    Shadow.Visible = false
end

local function OpenUI()
    MainFrame.Visible = true
    Shadow.Visible = true
    MainFrame.Size = UDim2.new(0, CONFIG.WindowWidth, 0, 0)
    isOpen = true
    Tween(MainFrame, {Size = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight)}, 0.4, Enum.EasingStyle.Back)
    Tween(Shadow, {ImageTransparency = 0.4}, 0.35)
    SelectTab(1)
end

CloseBtn.MouseButton1Click:Connect(function()
    CloseUI()
end)

MinBtn.MouseButton1Click:Connect(function()
    CloseUI()
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.ToggleKey then
        if isOpen then
            CloseUI()
        else
            OpenUI()
        end
    end
end)

-- ═══════════════════════════════════════
-- TABS & FEATURES
-- ═══════════════════════════════════════

-- ─── Main Tab ───
local MainTab = Library:AddTab("Main", "🪑")
MainTab:AddSection("Chair Teleport")
MainTab:AddLabel("TPs you to a chair non-stop until you're sitting or close to one.")
MainTab:AddToggle("Goto Chairs Automatically", false, function(state)
    ScriptState.AutoChair = state
    if state then
        local seats = GetAllSeats()
        if #seats > 0 then
            StartAutoChair()
            Notify("Auto Chair", "Found " .. #seats .. " seats! Moving now.", 3, "success")
        else
            ScriptState.AutoChair = false
            Notify("Auto Chair", "0 seats found. Is the round active?", 4, "error")
        end
    else
        StopAutoChair()
        Notify("Auto Chair", "Stopped.", 2, "error")
    end
end)

MainTab:AddSeparator()
MainTab:AddAccentButton("Go To Chair Now", function()
    task.spawn(function()
        local success = TweenAboveChair()
        if success then
            Notify("Chair", "Above a chair! Dropping...", 2, "success")
            task.wait(0.1)
            DropOntoChair()
        else
            Notify("Chair", "No chairs found!", 2, "error")
        end
    end)
end)

-- ─── Speed Tab ───
local SpeedTab = Library:AddTab("Speed", "💨")
SpeedTab:AddSection("Tween Speed")
SpeedTab:AddLabel("How fast you glide to a chair (studs/sec).")
SpeedTab:AddLabel("Lower = more natural, less likely to get flagged.")
SpeedTab:AddSlider("Tween Speed", 10, 200, 50, function(val)
    ScriptState.TweenSpeed = val
end)
SpeedTab:AddSeparator()
SpeedTab:AddButton("Sneaky (25)", function()
    ScriptState.TweenSpeed = 25
    Notify("Speed", "Tween speed: 25 (sneaky)", 2)
end)
SpeedTab:AddButton("Normal (50)", function()
    ScriptState.TweenSpeed = 50
    Notify("Speed", "Tween speed: 50 (normal)", 2)
end)
SpeedTab:AddButton("Fast (100)", function()
    ScriptState.TweenSpeed = 100
    Notify("Speed", "Tween speed: 100 (fast)", 2)
end)
SpeedTab:AddButton("Risky (200)", function()
    ScriptState.TweenSpeed = 200
    Notify("Speed", "Tween speed: 200 (risky!)", 2, "warning")
end)

-- ─── Misc Tab ───
local MiscTab = Library:AddTab("Misc", "🔧")
MiscTab:AddSection("Anti-AFK")
MiscTab:AddLabel("Prevents you from being kicked for being idle.")
MiscTab:AddToggle("Anti-AFK", true, function(state)
    ScriptState.AntiAFK = state
    if state then
        StartAntiAFK()
        Notify("Anti-AFK", "Anti-AFK enabled. You won't be kicked.", 3, "success")
    else
        StopAntiAFK()
        Notify("Anti-AFK", "Anti-AFK disabled.", 2, "error")
    end
end)
MiscTab:AddSeparator()
MiscTab:AddSection("Utilities")
MiscTab:AddButton("Rejoin Server", function()
    Notify("Rejoin", "Rejoining server...", 2, "warning")
    task.wait(1)
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)
MiscTab:AddButton("Copy Server Link", function()
    if setclipboard then
        setclipboard("roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId)
        Notify("Copied", "Server link copied to clipboard!", 2, "success")
    else
        Notify("Error", "Clipboard not supported by your executor.", 3, "error")
    end
end)

-- ─── Settings Tab ───
local SettingsTab = Library:AddTab("Settings", "⚙️")
SettingsTab:AddSection("UI Settings")
SettingsTab:AddButton("Reset Position", function()
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Notify("Settings", "Position reset to center.", 2)
end)
SettingsTab:AddButton("Destroy UI", function()
    StopAutoChair()
    StopAntiAFK()
    ScreenGui:Destroy()
end)
SettingsTab:AddSeparator()
SettingsTab:AddLabel("Toggle UI: RightShift")
SettingsTab:AddLabel("Drag the top bar to move the window.")
SettingsTab:AddLabel("Script by CozzyBruh")

-- ═══════════════════════════════════════
-- STARTUP
-- ═══════════════════════════════════════
task.wait(0.5)
Notify("Musical Chairs", "Loaded successfully! Made by CozzyBruh", 4, "success")
