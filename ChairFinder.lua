--[[
    Musical Chairs — Chair Finder Module
    Finds all sittable seats inside the correct "Chairs" model in workspace.
    Handles duplicate "Chairs" objects by checking which one has Chair children.
]]

local ChairFinder = {}

function ChairFinder.GetAllSeats()
    local seats = {}
    
    -- There are MULTIPLE things named "Chairs" in workspace.
    -- We need the one that actually contains "Chair" models inside it.
    local chairsFolder = nil
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Chairs" then
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
    
    -- Fallback: any "Chairs" with children
    if not chairsFolder then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == "Chairs" and #obj:GetChildren() > 0 then
                chairsFolder = obj
                break
            end
        end
    end
    
    if not chairsFolder then return seats end
    
    -- Priority 1: Seat / VehicleSeat instances
    for _, desc in pairs(chairsFolder:GetDescendants()) do
        if desc:IsA("Seat") or desc:IsA("VehicleSeat") then
            table.insert(seats, desc)
        end
    end
    
    -- Priority 2: BasePart from each Chair model
    if #seats == 0 then
        for _, child in pairs(chairsFolder:GetChildren()) do
            if child:IsA("Model") then
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
    
    -- Priority 3: any BasePart descendant
    if #seats == 0 then
        for _, desc in pairs(chairsFolder:GetDescendants()) do
            if desc:IsA("BasePart") then
                table.insert(seats, desc)
            end
        end
    end
    
    return seats
end

function ChairFinder.GetClosestSeat(seats, position)
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

return ChairFinder
