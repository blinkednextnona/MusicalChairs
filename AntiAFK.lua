--[[
    Musical Chairs — Anti-AFK Module
    Prevents idle kicks using VirtualUser.
    Hooks into Player.Idled event.
]]

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer

local AntiAFK = {}
AntiAFK._connection = nil

function AntiAFK.Start()
    if AntiAFK._connection then return end
    
    AntiAFK._connection = Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

function AntiAFK.Stop()
    if AntiAFK._connection then
        AntiAFK._connection:Disconnect()
        AntiAFK._connection = nil
    end
end

return AntiAFK
