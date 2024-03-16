SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Power = SWS.Power or {}

SWS.Power.POLL_INTERVAL = 5

//////////////////////
// Power Management //
//////////////////////

function SWS.Power:SetTotalPower(newPower)
    SWS.Power.totalPower = math.max(newPower, 0)
end

function SWS.Power:SetFreePower(newPower)
    SWS.Power.freePower = math.max(newPower, 0)
end

function SWS.Power:AddPower(power)
    SWS.Power:SetTotalPower(SWS.Power:GetTotalPower() + power)
    SWS.Power:SetFreePower(SWS.Power:GetFreePower() + power)

    net.Start("SWS.Power.UpdatePower")
        net.WriteUInt(SWS.Power:GetTotalPower(), 8)
        net.WriteUInt(SWS.Power:GetFreePower(), 8)
    net.Broadcast()
end

function SWS.Power:RemovePower(power)
    --remove allocated power from systems by priority first
    if SWS.Power.freePower < power then
        local remainder = math.abs(SWS.Power.freePower - power)
        for i = #SWS.Power.systems, 1, -1 do
            local sys, index = SWS.Power:GetSystem(i)
            if remainder <= 0 then break end
            if sys.power > 0 then
                local powerToRemove = sys.power > remainder and remainder or sys.power
                SWS.Power:SetSystemPower(sys.name, sys.power - powerToRemove)
                remainder = remainder - powerToRemove
            end
        end
    end
    
    SWS.Power:SetTotalPower(SWS.Power:GetTotalPower() - power)
    SWS.Power:SetFreePower(SWS.Power:GetFreePower() - power)

    net.Start("SWS.Power.UpdatePower")
        net.WriteUInt(SWS.Power:GetTotalPower(), 8)
        net.WriteUInt(SWS.Power:GetFreePower(), 8)
    net.Broadcast()
end

function SWS.Power:SetSystemPower(identifier, newValue)
    local system, index = SWS.Power:GetSystem(identifier)
    system.power = math.Clamp(newValue, 0, SWS.Power:GetSystemMaxPower(identifier))

    -- inform the system that its power allocation has changed
    local updateFunc = SWS.Power:GetSystemUpdateFunc(identifier)
    updateFunc(SWS.Power:GetSystemPower(identifier))

    net.Start("SWS.Power.UpdateSystem")
        net.WriteUInt(index, 8)
        net.WriteString(util.TableToJSON(table.Copy(system)))
    net.Broadcast()
end

-- this sets the value, if possible. It does not just add.
-- prolly way to complicated... can't think of a better way right now tho :/
function SWS.Power:AllocatePower(identifier, power)
    local system, index = SWS.Power:GetSystem(identifier)
    if system.power == power then return end

    power = math.Clamp(power, 0, system.maxPower)
    local adding = system.power < power and true or false
    local powerDiff = math.abs(system.power - power)

    if adding then
        if SWS.Power:GetFreePower() <= 0 then return end
        local additionalPower = SWS.Power:GetFreePower() >= powerDiff and powerDiff or SWS.Power:GetFreePower()

        SWS.Power:SetSystemPower(identifier, SWS.Power:GetSystemPower(identifier) + additionalPower)
        SWS.Power:SetFreePower(SWS.Power:GetFreePower() - additionalPower)
    else
        SWS.Power:SetSystemPower(identifier, SWS.Power:GetSystemPower(identifier) - powerDiff)
        SWS.Power:SetFreePower(SWS.Power:GetFreePower() + powerDiff)
    end
end

///////////////////////////////
// Power Provider Management //
///////////////////////////////

function SWS.Power:RegisterPowerProvider(name, getPowerFunc)
    table.insert(SWS.Power.powerProvider, {name = name, getPower = getPowerFunc})
end

function SWS.Power:UnregisterPowerProvider(name)
    for i,powerProvider in ipairs(SWS.Power.powerProvider) do
        if powerProvider.name == name then
            table.remove(SWS.Power.powerProvider, i)
        end
    end
end

timer.Create("SWS.Power.PollPower", SWS.Power.POLL_INTERVAL, 0, function()
    local availablePower = 0
    for i, powerProvider in ipairs(SWS.Power.powerProvider) do
        availablePower = availablePower + powerProvider:getPower()
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

function SWS.Power:RegisterSystem(name, maxPower, update)
    local system = {name = name, power = 0, maxPower = maxPower, update = update}
    table.insert(SWS.Power.systems, system)

    net.Start("SWS.Power.RegisterSystem")
        net.WriteString(util.TableToJSON(table.Copy(system)))
    net.Broadcast()
end

function SWS.Power:UnregisterSystem(identifier)
    local _, index = SWS.Power:GetSystem(identifier)
    
    SWS.Power:AllocatePower(identifier, 0)
    table.remove(SWS.Power.systems, index)

    net.Start("SWS.Power.UnregisterSystem")
        net.WriteUInt(index, 8)
    net.Broadcast()
end

local function swapSystems(index1, index2)
    local temp = table.Copy(SWS.Power.systems[index1])
    SWS.Power.systems[index1] = table.Copy(SWS.Power.systems[index2])
    SWS.Power.systems[index2] = table.Copy(temp)

    net.Start("SWS.Power.SwapSystems")
        net.WriteUInt(index1, 8)
        net.WriteUInt(index2, 8)
    net.Broadcast()
end

function SWS.Power:IncreaseSystemPriority(identifier)
    local _, index = SWS.Power:GetSystem(identifier)
    if index <= 1 then return end

    swapSystems(index, index-1)
end

function SWS.Power:DecreaseSystemPriority(identifier)
    local _, index = SWS.Power:GetSystem(identifier)
    if index >= #SWS.Power.systems then return end

    swapSystems(index, index+1)
end

////////////////
// Networking //
////////////////

util.AddNetworkString("SWS.Power.SyncData")
util.AddNetworkString("SWS.Power.UpdateSystem")
util.AddNetworkString("SWS.Power.UpdatePower")
util.AddNetworkString("SWS.Power.SwapSystems")
util.AddNetworkString("SWS.Power.RegisterSystem")
util.AddNetworkString("SWS.Power.UnregisterSystem")

hook.Add("SWS.PlayerLoaded", "SWS.Power.SyncData", function(ply)
    net.Start("SWS.Power.SyncData")
        net.WriteUInt(SWS.Power:GetTotalPower(), 8)
        net.WriteUInt(SWS.Power:GetFreePower(), 8)

        net.WriteString(util.TableToJSON(table.Copy(SWS.Power.powerProvider)))
        net.WriteString(util.TableToJSON(table.Copy(SWS.Power.systems)))
    net.Send(ply)
end)

SWS.Power:RegisterSystem("testSystem1", 10, function() end)
SWS.Power:RegisterSystem("testSystem2", 10, function() end)
SWS.Power:RegisterSystem("testSystem3", 10, function() end)
--SWS.Power:UnregisterSystem("testSystem3")