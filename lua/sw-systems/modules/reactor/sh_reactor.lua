SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Reactor = SWS.Reactor or {}

SWS.Reactor.status = SWS.ENUM.REACTOR_STATUS.OPERATIONAL

SWS.Reactor.powerOutput = 0
SWS.Reactor.MAX_POWER_OUTPUT = 10

SWS.Reactor.coolingPower = 0
SWS.Reactor.MAX_COOLING_POWER = 10

SWS.Reactor.heat = 0
SWS.Reactor.MAX_HEAT = 10
SWS.Reactor.HEAT_INTERVAL = 5

function SWS.Reactor:GetStatus()
    return SWS.Reactor.status
end

function SWS.Reactor:GetPowerOutput()
    return SWS.Reactor.powerOutput
end

function SWS.Reactor:GetCoolingPower()
    return SWS.Reactor.coolingPower
end

function SWS.Reactor:GetHeat()
    return SWS.Reactor.heat
end