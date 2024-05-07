SWS = SWS or {}
SWS.Power = SWS.Power or {}

local GENERATOR = {}
GENERATOR.IDENTIFIER = "Reactor"

function GENERATOR:Initialize()
    timer.Create("SWS.Reactor.heatClock", self.HEAT_INTERVAL, 0, function()
        local diff = self:GetPowerOutput() - self:GetCoolingPower()
    
        if self:GetStatus() == self.REACTOR_STATUS.MELTDOWN then return end
    
        if self:GetHeat() >= self.MAX_HEAT and diff > 0 then
            self:SetStatus(self.REACTOR_STATUS.MELTDOWN)
            self:SetPowerOutput(0)
        end
    
        if diff > 0 then
            self:SetHeat(self:GetHeat()+diff)
        elseif diff < 0 then
            self:SetHeat(self:GetHeat()-math.abs(diff))
        end
    end)

    hook.Add("SWS.PlayerLoaded", "SWS.Reactor.SyncData", function(ply)
        net.Start("SWS.Reactor.SyncData")
            net.WriteUInt(SWS.Generators.Reactor:GetStatus(), 4)
            net.WriteUInt(SWS.Generators.Reactor:GetPowerOutput(), 8)
            net.WriteUInt(SWS.Generators.Reactor:GetCoolingPower(), 8)
            net.WriteUInt(SWS.Generators.Reactor:GetHeat(), 8)
        net.Send(ply)
    end)

    self:SetCoolingPower(10)
    self:SetPowerOutput(10)

    SWS.Power:RegisterGenerator(self)
end

function GENERATOR:SetStatus(status)
    self.status = math.Clamp(status, 1, table.Count(self.REACTOR_STATUS))
    net.Start("SWS.Reactor.Status")
        net.WriteUInt(self:GetStatus(), 4)
    net.Broadcast()
end

function GENERATOR:SetPowerOutput(number)
    if self:GetStatus() == self.REACTOR_STATUS.MELTDOWN then return end
    self.powerOutput = math.Clamp(number, 0, self.MAX_POWER_OUTPUT)
    net.Start("SWS.Reactor.Power")
        net.WriteUInt(self:GetPowerOutput(), 8)
    net.Broadcast()
end

function GENERATOR:SetCoolingPower(number)
    self.coolingPower = math.Clamp(number, 0, self.MAX_COOLING_POWER)
    net.Start("SWS.Reactor.Cooling")
        net.WriteUInt(self:GetCoolingPower(), 8)
    net.Broadcast()
end

function GENERATOR:SetHeat(number)
    self.heat = math.Clamp(number, 0, self.MAX_HEAT)
    net.Start("SWS.Reactor.Heat")
        net.WriteUInt(self:GetHeat(), 8)
    net.Broadcast()
end

////////////////
// Networking //
////////////////

util.AddNetworkString("SWS.Reactor.Status")
util.AddNetworkString("SWS.Reactor.Power")
util.AddNetworkString("SWS.Reactor.Cooling")
util.AddNetworkString("SWS.Reactor.Heat")
util.AddNetworkString("SWS.Reactor.SyncData")

net.Receive("SWS.Reactor.Power", function(len, ply)
    local trEnt = ply:GetEyeTraceNoCursor().Entity
    if (trEnt and trEnt ~= NULL and trEnt:GetClass() == "sws_reactor_terminal") or SWS.IsAdmin(ply) then
        SWS.Generators.Reactor:SetPowerOutput(net.ReadUInt(8))
    end
end)

net.Receive("SWS.Reactor.Cooling", function(len, ply)
    local trEnt = ply:GetEyeTraceNoCursor().Entity
    if (trEnt and trEnt ~= NULL and trEnt:GetClass() == "sws_reactor_terminal") or SWS.IsAdmin(ply) then
        SWS.Generators.Reactor:SetCoolingPower(net.ReadUInt(8))
    end
end)

-- todo: rework into command or automation on cleanup
concommand.Add("reset_reactor", function(ply, cmd)
    SWS.Generators.Reactor:SetStatus(1)
    SWS.Generators.Reactor:SetPowerOutput(0)
    SWS.Generators.Reactor:SetCoolingPower(0)
    SWS.Generators.Reactor:SetHeat(0)
end)

SWS.LoadGenerator(GENERATOR)