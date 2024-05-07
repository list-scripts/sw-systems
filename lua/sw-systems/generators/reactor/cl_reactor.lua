SWS = SWS or {}

local GENERATOR = {}
GENERATOR.IDENTIFIER = "Reactor"

GENERATOR.ICON = Material("sw-systems/icons/generators/reactor.png", "noclamp smooth")

function GENERATOR:Initialize()
    
end

////////////////
// Networking //
////////////////

net.Receive("SWS.Reactor.Status", function(len, ply)
    SWS.Generators.Reactor.status = net.ReadUInt(4)
end)

net.Receive("SWS.Reactor.Power", function(len, ply)
    SWS.Generators.Reactor.powerOutput = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.Cooling", function(len, ply)
    SWS.Generators.Reactor.coolingPower = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.Heat", function(len, ply)
    SWS.Generators.Reactor.heat = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.SyncData", function(len, ply)
    SWS.Generators.Reactor.status = net.ReadUInt(4)
    SWS.Generators.Reactor.powerOutput = net.ReadUInt(8)
    SWS.Generators.Reactor.coolingPower = net.ReadUInt(8)
    SWS.Generators.Reactor.heat = net.ReadUInt(8)
end)

////////////
// Setter //
////////////

function GENERATOR:SetPowerOutput(number)
    net.Start("SWS.Reactor.Power")
        net.WriteUInt(math.Clamp(number, 0, self:GetMaxPowerOutput()), 8)
    net.SendToServer()
end

function GENERATOR:SetCoolingPower(number)
    net.Start("SWS.Reactor.Cooling")
        net.WriteUInt(math.Clamp(number, 0, self:GetMaxCoolingPower()), 8)
    net.SendToServer()
end

SWS.LoadGenerator(GENERATOR)