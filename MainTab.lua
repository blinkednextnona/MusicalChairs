--[[
    Musical Chairs — Main Tab
    Contains: Auto chair toggle, manual "Go To Chair Now" button.
    
    This tab is the core of the script. The toggle starts/stops the
    auto chair loop which tweens above chairs and drops the player.
]]

-- In Main.lua, this section looks like:
--
-- local MainTab = Library:AddTab("Main", "🪑")
-- MainTab:AddSection("Chair Teleport")
-- MainTab:AddLabel("TPs you to a chair non-stop until you're sitting or close to one.")
-- MainTab:AddToggle("Goto Chairs Automatically", false, function(state)
--     ScriptState.AutoChair = state
--     if state then
--         local seats = GetAllSeats()
--         if #seats > 0 then
--             StartAutoChair()
--             Notify("Auto Chair", "Found " .. #seats .. " seats! Moving now.", 3, "success")
--         else
--             ScriptState.AutoChair = false
--             Notify("Auto Chair", "0 seats found. Is the round active?", 4, "error")
--         end
--     else
--         StopAutoChair()
--         Notify("Auto Chair", "Stopped.", 2, "error")
--     end
-- end)
--
-- MainTab:AddSeparator()
-- MainTab:AddAccentButton("Go To Chair Now", function()
--     task.spawn(function()
--         local success = TweenAboveChair()
--         if success then
--             Notify("Chair", "Above a chair! Dropping...", 2, "success")
--             task.wait(0.1)
--             DropOntoChair()
--         else
--             Notify("Chair", "No chairs found!", 2, "error")
--         end
--     end)
-- end)

return "MainTab"
