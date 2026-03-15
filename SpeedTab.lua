--[[
    Musical Chairs — Speed Tab
    Controls tween speed (studs/sec) — how fast the player glides to chairs.
    
    Slider: 10 - 200 studs/sec
    Presets: Sneaky (25), Normal (50), Fast (100), Risky (200)
    
    Lower speeds look more natural and are less likely to trigger detection.
]]

-- In Main.lua, this section looks like:
--
-- local SpeedTab = Library:AddTab("Speed", "💨")
-- SpeedTab:AddSection("Tween Speed")
-- SpeedTab:AddLabel("How fast you glide to a chair (studs/sec).")
-- SpeedTab:AddLabel("Lower = more natural, less likely to get flagged.")
-- SpeedTab:AddSlider("Tween Speed", 10, 200, 50, function(val)
--     ScriptState.TweenSpeed = val
-- end)
-- SpeedTab:AddSeparator()
-- SpeedTab:AddButton("Sneaky (25)", ...)
-- SpeedTab:AddButton("Normal (50)", ...)
-- SpeedTab:AddButton("Fast (100)", ...)
-- SpeedTab:AddButton("Risky (200)", ...)

return "SpeedTab"
