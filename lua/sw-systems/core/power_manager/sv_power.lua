SWS = SWS or {}
SWS.Power = SWS.Power or {}

SWS.Power.POLL_INTERVAL = 2

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
            if SWS.Power:GetSystemPower(index) > 0 then
                local powerToRemove = SWS.Power:GetSystemPower(index) > remainder and remainder or SWS.Power:GetSystemPower(index)
                SWS.Power:SetSystemPower(index, SWS.Power:GetSystemPower(index) - powerToRemove)
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
    system.power = math.Clamp(newValue, 0, SWS.Power:GetSystemMaxPower(identifier))

    system:HandlePowerChange(SWS.Power:GetSystemPower(identifier))

    net.Start("SWS.Power.UpdateSystem")
        net.WriteUInt(index, 8)
        net.WriteUInt(system.power, 8)
    net.Broadcast()
end

-- this sets the value, if possible. It does not just add.
-- prolly way to complicated... can't think of a better way right now tho :/
function SWS.Power:AllocatePower(identifier, power)
    local system, index = SWS.Power:GetSystem(identifier)
    if system.power == power then return end

    power = math.Clamp(power, 0, system.MAX_POWER)
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

//////////////////////////
// Generator Management //
//////////////////////////

function SWS.Power:RegisterGenerator(generator)
    table.insert(SWS.Power.activeGenerators, generator)
    net.Start("SWS.Power.RegisterGenerator")
        net.WriteString(generator.IDENTIFIER)
    net.Broadcast()
end

function SWS.Power:UnregisterGenerator(identifier)
    for index, generator in ipairs(SWS.Power.activeGenerators) do
        if generator.IDENTIFIER == identifier then
            table.remove(SWS.Power.activeGenerators, index)
            net.Start("SWS.Power.UnregisterGenerator")
                net.WriteUInt(index, 8)
            net.Broadcast()
        end
    end
end

timer.Create("SWS.Power.PollPower", SWS.Power.POLL_INTERVAL, 0, function()
    local availablePower = 0
    for i, generator in ipairs(SWS.Power.activeGenerators) do
        availablePower = availablePower + generator:GetPowerOutput()
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

function SWS.Power:RegisterSystem(system)
    local index = table.insert(SWS.Power.activeSystems, system)

    net.Start("SWS.Power.RegisterSystem")
        net.WriteString(system.IDENTIFIER)
    net.Broadcast()

    if system.PREFERRED_INITIAL_POWER then
        -- this is hacky, maybe there is a better way
        -- need to wait for the generators to provide power first
        timer.Simple(5, function()
            SWS.Power:AllocatePower(index, system.PREFERRED_INITIAL_POWER)
        end)
    end
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
util.AddNetworkString("SWS.Power.RegisterGenerator")
util.AddNetworkString("SWS.Power.UnregisterGenerator")
util.AddNetworkString("SWS.Power.IncreaseSystemPriority")
util.AddNetworkString("SWS.Power.DecreaseSystemPriority")
util.AddNetworkString("SWS.Power.IncreasePower")
util.AddNetworkString("SWS.Power.DecreasePower")

net.Receive("SWS.Power.IncreaseSystemPriority", function(len, ply)
    local trEnt = ply:GetEyeTraceNoCursor().Entity
    if (trEnt and trEnt ~= NULL and trEnt:GetClass() == "sws_power_terminal") or SWS.IsAdmin(ply) then
        SWS.Power:IncreaseSystemPriority(net.ReadUInt(8))
    end
end)

net.Receive("SWS.Power.DecreaseSystemPriority", function(len, ply)
    local trEnt = ply:GetEyeTraceNoCursor().Entity
    if (trEnt and trEnt ~= NULL and trEnt:GetClass() == "sws_power_terminal") or SWS.IsAdmin(ply) then
        SWS.Power:DecreaseSystemPriority(net.ReadUInt(8))
    end
end)

net.Receive("SWS.Power.IncreasePower", function(len, ply)
    local trEnt = ply:GetEyeTraceNoCursor().Entity
    if (trEnt and trEnt ~= NULL and trEnt:GetClass() == "sws_power_terminal") or SWS.IsAdmin(ply) then
        local system, index = SWS.Power:GetSystem(net.ReadUInt(8))
        SWS.Power:AllocatePower(index, system.power + 1)
    end
end)

net.Receive("SWS.Power.DecreasePower", function(len, ply)
    local trEnt = ply:GetEyeTraceNoCursor().Entity
    if (trEnt and trEnt ~= NULL and trEnt:GetClass() == "sws_power_terminal") or SWS.IsAdmin(ply) then
        local system, index = SWS.Power:GetSystem(net.ReadUInt(8))
        SWS.Power:AllocatePower(index, system.power - 1)
    end
end)

hook.Add("SWS.PlayerLoaded", "SWS.Power.SyncData", function(ply)
    net.Start("SWS.Power.SyncData")
        net.WriteUInt(SWS.Power:GetTotalPower(), 8)
        net.WriteUInt(SWS.Power:GetFreePower(), 8)

        local generatorIdentifiers = {}
        for i, generator in ipairs(SWS.Power.activeGenerators) do
            table.insert(generatorIdentifiers, generator.IDENTIFIER)
        end

        local systemIdentifiers = {}
        for i, system in ipairs(SWS.Power.activeSystems) do
            table.insert(systemIdentifiers, system.IDENTIFIER)
        end

        net.WriteString(util.TableToJSON(table.Copy(generatorIdentifiers)))
        net.WriteString(util.TableToJSON(table.Copy(systemIdentifiers)))
    net.Send(ply)
end)