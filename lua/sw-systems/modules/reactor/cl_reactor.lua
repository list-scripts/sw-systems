SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Reactor = SWS.Reactor or {}

////////////////
// Networking //
////////////////

net.Receive("SWS.Reactor.Status", function(len, ply)
    SWS.Reactor.status = net.ReadUInt(4)
end)

net.Receive("SWS.Reactor.Power", function(len, ply)
    SWS.Reactor.powerOutput = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.Cooling", function(len, ply)
    SWS.Reactor.coolingPower = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.Heat", function(len, ply)
    SWS.Reactor.heat = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.SyncData", function(len, ply)
    SWS.Reactor.status = net.ReadUInt(4)
    SWS.Reactor.powerOutput = net.ReadUInt(8)
    SWS.Reactor.coolingPower = net.ReadUInt(8)
    SWS.Reactor.heat = net.ReadUInt(8)
end)

////////////
// Setter //
////////////

function SWS.Reactor:SetPowerOutput(number)
    net.Start("SWS.Reactor.Power")
        net.WriteUInt(math.Clamp(number, 0, SWS.Reactor.MAX_POWER_OUTPUT), 8)
    net.SendToServer()
end

function SWS.Reactor:SetCoolingPower(number)
    net.Start("SWS.Reactor.Cooling")
        net.WriteUInt(math.Clamp(number, 0, SWS.Reactor.MAX_COOLING_POWER), 8)
    net.SendToServer()
end