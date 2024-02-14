SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Power = SWS.Power or {}

SWS.Power.POLL_INTERVAL = 5

SWS.Power.totalPower = 0
SWS.Power.freePower = 0

SWS.Power.powerProvider = {}
SWS.Power.systems = {}

//////////////////////
// Power Management //
//////////////////////

function SWS.Power:GetTotalPower()
    return SWS.Power.totalPower
end

function SWS.Power:SetTotalPower(newPower)
    SWS.Power.totalPower = math.max(newPower, 0)
end

function SWS.Power:GetFreePower()
    return SWS.Power.freePower
end

function SWS.Power:SetFreePower(newPower)
    SWS.Power.freePower = math.max(newPower, 0)
end

function SWS.Power:AddPower(power)
    SWS.Power:SetTotalPower(SWS.Power:GetTotalPower() + power)
    SWS.Power:SetFreePower(SWS.Power:GetFreePower() + power)
end

function SWS.Power:RemovePower(power)
    if SWS.Power.freePower < power then
        local remainder = math.abs(SWS.Power.totalPower - power)
        -- remove the power we give systems by priority
    end
    
    SWS.Power:SetTotalPower(SWS.Power:GetTotalPower() - power)
    SWS.Power:SetFreePower(SWS.Power:GetFreePower() - power)
end

-- this sets the value, if possible. It does not just add.
-- prolly way to complicated... can't think of a better way right now tho :/
function SWS.Power:AllocatePower(name, power)
    local systemIndex = SWS.Power:GetSystemIndexByName(name)
    local system = SWS.Power.systems[systemIndex]
    if system.currentPower == power then return end

    power = math.Clamp(power, 0, system.maxPower)
    local adding = system.currentPower < power and true or false
    local powerDiff = math.abs(system.currentPower - power)

    if adding then
        if SWS.Power:GetFreePower() <= 0 then return end
        local additionalPower = SWS.Power:GetFreePower() >= powerDiff and powerDiff or SWS.Power:GetFreePower()

        SWS.Power.systems[systemIndex].currentPower = SWS.Power.systems[systemIndex].currentPower + additionalPower
        SWS.Power:SetFreePower(SWS.Power:GetFreePower() - additionalPower)
    else
        SWS.Power.systems[systemIndex].currentPower = SWS.Power.systems[systemIndex].currentPower - powerDiff
        SWS.Power:SetFreePower(SWS.Power:GetFreePower() + powerDiff)
    end

    SWS.Power.systems[systemIndex].checkNewAllocation(SWS.Power.systems[systemIndex].currentPower) -- inform the system that its power allocation has changed
end

///////////////////////////////
// Power Provider Management //
///////////////////////////////

function SWS.Power:RegisterPowerProvider(name, getPowerFunction)
    table.insert(SWS.Power.powerProvider, {name = name, GetPower = getPowerFunction})
end

function SWS.Power:UnregisterPowerProvider(name)
    for i,v in ipairs(SWS.Power.powerProvider) do
        if v.name == name then
            table.remove(SWS.Power.powerProvider, i)
        end
    end
end

timer.Create("SWS.Power.PollPower", SWS.Power.POLL_INTERVAL, 0, function()
    local availablePower = 0
    for i,v in ipairs(SWS.Power.powerProvider) do
        availablePower = availablePower + v:GetPower()
    end

    if availablePower > SWS.Power:GetTotalPower() then
        SWS.Power:AddPower(availablePower - SWS.Power:GetTotalPower())
    else
        SWS.Power:RemovePower(SWS.Power:GetTotalPower() - availablePower)
    end
end)

///////////////////////
// System Management //
///////////////////////

function SWS.Power:GetSystemIndexByName(name)
    for i,v in ipairs(SWS.Power.systems) do
        if v.name == name then
            return i
        end
    end
end

function SWS.Power:RegisterSystem(name, maxPower, checkNewAllocation)
    table.insert(SWS.Power.systems, {name = name, currentPower = 0, maxPower = maxPower, checkNewAllocation = checkNewAllocation})
end

function SWS.Power:UnregisterSystem(name)
    for i,v in ipairs(SWS.Power.systems) do
        if v.name == name then
            table.remove(SWS.Power.systems, i)
        end
    end
end

function SWS.Power:IncreaseSystemPriority(name)
    local systemIndex = SWS.Power:GetSystemIndexByName(name)
    if systemIndex <= 1 then return end

    local temp = table.Copy(SWS.Power.systems[systemIndex])
    SWS.Power.systems[systemIndex] = table.Copy(SWS.Power.systems[systemIndex-1])
    SWS.Power.systems[systemIndex-1] = table.Copy(temp)
end

function SWS.Power:DecreaseSystemPriority(name)
    local systemIndex = SWS.Power:GetSystemIndexByName(name)
    if systemIndex >= #SWS.Power.systems then return end

    local temp = table.Copy(SWS.Power.systems[systemIndex])
    SWS.Power.systems[systemIndex] = table.Copy(SWS.Power.systems[systemIndex+1])
    SWS.Power.systems[systemIndex+1] = table.Copy(temp)
end

SWS.Power:RegisterSystem("testSystem1", 10, function() end)
SWS.Power:RegisterSystem("testSystem2", 10, function() end)
SWS.Power:RegisterSystem("testSystem3", 10, function() end)