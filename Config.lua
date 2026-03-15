--[[
    Musical Chairs — UI Configuration
    All colors, fonts, sizes, and layout constants.
]]

local Config = {
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

return Config
