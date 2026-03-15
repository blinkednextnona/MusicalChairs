--[[
    Musical Chairs — Misc Tab
    Contains: Anti-AFK toggle, Rejoin Server, Copy Server Link.
    
    Anti-AFK is enabled by default and uses VirtualUser to prevent idle kicks.
]]

-- In Main.lua, this section looks like:
--
-- local MiscTab = Library:AddTab("Misc", "🔧")
-- MiscTab:AddSection("Anti-AFK")
-- MiscTab:AddLabel("Prevents you from being kicked for being idle.")
-- MiscTab:AddToggle("Anti-AFK", true, function(state)
--     ScriptState.AntiAFK = state
--     if state then StartAntiAFK() else StopAntiAFK() end
-- end)
-- MiscTab:AddSeparator()
-- MiscTab:AddSection("Utilities")
-- MiscTab:AddButton("Rejoin Server", ...)
-- MiscTab:AddButton("Copy Server Link", ...)

return "MiscTab"
