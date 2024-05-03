SWS = SWS or {}
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
        for i = #SWS.Power.activeSystems, 1, -1 do
            local system, index = SWS.Power:GetSystem(i)
            if remainder <= 0 then break end
            if system.currentPower > 0 then
                local powerToRemove = system.currentPower > remainder and remainder or system.currentPower
                SWS.Power:SetSystemPower(system.name, system.currentPower - powerToRemove)
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

-- don't use this function to set power, use AllocatePower instead
-- its only for internal use
function SWS.Power:SetSystemPower(identifier, newValue)
    local system, index = SWS.Power:GetSystem(identifier)
    system.currentPower = math.Clamp(newValue, 0, SWS.Power:GetSystemMaxPower(identifier))

    system.reference:HandlePowerChange(SWS.Power:GetSystemPower(identifier))

    net.Start("SWS.Power.UpdateSystem")
        net.WriteUInt(index, 8)
        net.WriteString(util.TableToJSON(table.Copy(system)))
    net.Broadcast()
end

-- this sets the value, if possible. It does not just add.
-- prolly way to complicated... can't think of a better way right now tho :/
function SWS.Power:AllocatePower(identifier, power)
    local system, index = SWS.Power:GetSystem(identifier)
    if system.currentPower == power then return end

    power = math.Clamp(power, 0, system.maxPower)
    local adding = system.currentPower < power and true or false
    local powerDiff = math.abs(system.currentPower - power)

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

function SWS.Power:RegisterPowerProvider(name, reference)
    table.insert(SWS.Power.powerProvider, {name = name, reference = reference})
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
        availablePower = availablePower + powerProvider.reference:GetPowerOutput()
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

function SWS.Power:RegisterSystem(name, maxPower, reference)
    local system = {name = name, currentPower = 0, maxPower = maxPower, reference = reference}
    table.insert(SWS.Power.activeSystems, system)

    net.Start("SWS.Power.RegisterSystem")
        net.WriteString(util.TableToJSON(table.Copy(system)))
    net.Broadcast()
end

function SWS.Power:UnregisterSystem(identifier)
    local _, index = SWS.Power:GetSystem(identifier)
    
    SWS.Power:AllocatePower(identifier, 0)
    table.remove(SWS.Power.activeSystems, index)

    net.Start("SWS.Power.UnregisterSystem")
        net.WriteUInt(index, 8)
    net.Broadcast()
end

local function swapSystems(index1, index2)
    local temp = table.Copy(SWS.Power.activeSystems[index1])
    SWS.Power.activeSystems[index1] = table.Copy(SWS.Power.activeSystems[index2])
    SWS.Power.activeSystems[index2] = table.Copy(temp)

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
    if index >= #SWS.Power.activeSystems then return end

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
        net.WriteString(util.TableToJSON(table.Copy(SWS.Power.activeSystems)))
    net.Send(ply)
end)