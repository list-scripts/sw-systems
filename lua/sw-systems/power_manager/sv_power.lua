SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Power = SWS.Power or {}

SWS.Power.POLL_INTERVAL = 5

SWS.Power.totalPower = 0
SWS.Power.freePower = 0

SWS.Power.powerProvider = {}
SWS.Power.systems = {}

function SWS.Power:GetTotalPower()
    return SWS.Power.totalPower
end

function SWS.Power:GetFreePower()
    return SWS.Power.freePower
end

function SWS.Power:AllocatePower(power)
    SWS.Power.totalPower = math.max(SWS.Power.totalPower + power, 0)
    SWS.Power.freePower = math.max(SWS.Power.freePower + power, 0)
end

function SWS.Power:DeallocatePower(power)
    if SWS.Power.freePower < power then
        local remainder = math.abs(SWS.Power.totalPower - power)
        -- remove the power we give systems by priority
    end
    
    SWS.Power.totalPower = math.max(SWS.Power.totalPower - power, 0)
    SWS.Power.freePower = math.max(SWS.Power.freePower - power, 0)
end

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
        SWS.Power:AllocatePower(availablePower - SWS.Power:GetTotalPower())
    else
        SWS.Power:DeallocatePower(SWS.Power:GetTotalPower() - availablePower)
    end
end)

function SWS.Power:AllocateSystemPower(name)
    
end

function SWS.Power:DeallocateSystemPower(name)
    
end

function SWS.Power:RegisterSystem(name, maxPower, allocatePower)
    table.insert(SWS.Power.systems, {name = name, currentPower = 0, maxPower = maxPower, allocatePower = allocatePower})
end

function SWS.Power:UnregisterSystem(name)
    for i,v in ipairs(SWS.Power.systems) do
        if v.name == name then
            table.remove(SWS.Power.systems, i)
        end
    end
end

function SWS.Power:GetSystemIndexByName(name)
    for i,v in ipairs(SWS.Power.systems) do
        if v.name == name then
            return i
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