--[[
    Musical Chairs — UI Library
    Clean dark-themed UI with draggable window, tabs, toggles, sliders, buttons.
    
    Usage:
        local Library = require(path.to.Library)
        local tab = Library:AddTab("Name", "Icon")
        tab:AddToggle("Label", false, function(state) end)
        tab:AddSlider("Label", 0, 100, 50, function(val) end)
        tab:AddButton("Label", function() end)
        tab:AddAccentButton("Label", function() end)
        tab:AddSection("Header")
        tab:AddLabel("Text")
        tab:AddSeparator()
]]

-- This file documents the UI library structure.
-- In the all-in-one Main.lua, this is embedded directly.
-- For modular usage, the UI components (Tween, CreateInstance, AddCorner, etc.)
-- along with the ScreenGui, MainFrame, Sidebar, ContentArea, and the Library
-- table with AddTab are all defined together.
--
-- See src/Main.lua for the complete implementation.
-- This file serves as documentation for the UI API.

local UILibrary = {}

UILibrary.Components = {
    "Tween(object, props, duration, style, direction)",
    "CreateInstance(className, properties, children)",
    "AddCorner(parent, radius)",
    "AddStroke(parent, color, thickness)",
    "AddPadding(parent, t, b, l, r)",
}

UILibrary.TabMethods = {
    "Tab:AddSection(text)       -- Section header label",
    "Tab:AddToggle(text, default, callback)  -- Toggle switch",
    "Tab:AddButton(text, callback)           -- Standard button",
    "Tab:AddAccentButton(text, callback)     -- Highlighted accent button",
    "Tab:AddSlider(text, min, max, default, callback) -- Value slider",
    "Tab:AddLabel(text)                      -- Info text",
    "Tab:AddSeparator()                      -- Horizontal line",
}

UILibrary.WindowFeatures = {
    "Draggable via top bar",
    "Close and minimize buttons",
    "RightShift keybind to toggle",
    "Smooth open/close animations",
    "Drop shadow",
    "Notification system (Notify function)",
}

return UILibrary
