SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Reactor = SWS.Reactor or {}

function SWS.Reactor:SetStatus(status)
    SWS.Reactor.status = math.Clamp(status, 1, table.Count(SWS.ENUM.REACTOR_STATUS))
    net.Start("SWS.Reactor.Status")
        net.WriteUInt(SWS.Reactor:GetStatus(), 4)
    net.Broadcast()
end

function SWS.Reactor:SetPowerOutput(number)
    if SWS.Reactor:GetStatus() == SWS.ENUM.REACTOR_STATUS.MELTDOWN then return end
    SWS.Reactor.powerOutput = math.Clamp(number, 0, SWS.Reactor.MAX_POWER_OUTPUT)
    net.Start("SWS.Reactor.Power")
        net.WriteUInt(SWS.Reactor:GetPowerOutput(), 8)
    net.Broadcast()
end

function SWS.Reactor:SetCoolingPower(number)
    SWS.Reactor.coolingPower = math.Clamp(number, 0, SWS.Reactor.MAX_COOLING_POWER)
    net.Start("SWS.Reactor.Cooling")
        net.WriteUInt(SWS.Reactor:GetCoolingPower(), 8)
    net.Broadcast()
end

function SWS.Reactor:SetHeat(number)
    SWS.Reactor.heat = math.Clamp(number, 0, SWS.Reactor.MAX_HEAT)
    net.Start("SWS.Reactor.Heat")
        net.WriteUInt(SWS.Reactor:GetHeat(), 8)
    net.Broadcast()
end

timer.Create("SWS.Reactor.heatClock", SWS.Reactor.HEAT_INTERVAL, 0, function()
    local diff = SWS.Reactor:GetPowerOutput() - SWS.Reactor:GetCoolingPower()

    if SWS.Reactor:GetStatus() == SWS.ENUM.REACTOR_STATUS.MELTDOWN then return end

    if SWS.Reactor:GetHeat() >= SWS.Reactor.MAX_HEAT and diff > 0 then
        SWS.Reactor:SetStatus(SWS.ENUM.REACTOR_STATUS.MELTDOWN)
        SWS.Reactor:SetPowerOutput(0)
    end

    if diff > 0 then
        SWS.Reactor:SetHeat(SWS.Reactor:GetHeat()+diff)
    elseif diff < 0 then
        SWS.Reactor:SetHeat(SWS.Reactor:GetHeat()-math.abs(diff))
    end
end)

////////////////
// Networking //
////////////////

util.AddNetworkString("SWS.Reactor.Status")
util.AddNetworkString("SWS.Reactor.Power")
util.AddNetworkString("SWS.Reactor.Cooling")
util.AddNetworkString("SWS.Reactor.Heat")
util.AddNetworkString("SWS.Reactor.SyncData")

net.Receive("SWS.Reactor.Power", function(len, ply)
    if not SWS.IsAdmin(ply) then return end
    local trEnt = ply:GetEyeTraceNoCursor().Entity
    if trEnt and trEnt ~= NULL and trEnt:GetClass() == "sws_reactor_terminal" then
        SWS.Reactor:SetPowerOutput(net.ReadUInt(8))
    end
end)

net.Receive("SWS.Reactor.Cooling", function(len, ply)
    if not SWS.IsAdmin(ply) then return end
    local trEnt = ply:GetEyeTraceNoCursor().Entity
    if trEnt and trEnt ~= NULL and trEnt:GetClass() == "sws_reactor_terminal" then
        SWS.Reactor:SetCoolingPower(net.ReadUInt(8))
    end
end)

hook.Add("SWS.PlayerLoaded", "SWS.Reactor.SyncData", function(ply)
    net.Start("SWS.Reactor.SyncData")
        net.WriteUInt(SWS.Reactor:GetStatus(), 4)
        net.WriteUInt(SWS.Reactor:GetPowerOutput(), 8)
        net.WriteUInt(SWS.Reactor:GetCoolingPower(), 8)
        net.WriteUInt(SWS.Reactor:GetHeat(), 8)
    net.Send(ply)
end)

-- todo: rework into command or automation on cleanup
concommand.Add("reset_reactor", function(ply, cmd)
    SWS.Reactor:SetStatus(1)
    SWS.Reactor:SetPowerOutput(0)
    SWS.Reactor:SetCoolingPower(0)
    SWS.Reactor:SetHeat(0)
end)