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

function SWS.Power:UnRegisterPowerProvider(name)
    for i,v in ipairs(SWS.Power.powerProvider) do
        if v.name == name then
            table.remove(SWS.Power.powerProvider, i)
            return
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