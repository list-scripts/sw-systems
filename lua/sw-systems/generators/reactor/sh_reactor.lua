SWS = SWS or {}

local GENERATOR = {}
GENERATOR.IDENTIFIER = "Reactor"

GENERATOR.NAME = "Reactor"

GENERATOR.REACTOR_STATUS = {}
GENERATOR.REACTOR_STATUS.OPERATIONAL = 1
GENERATOR.REACTOR_STATUS.DAMAGED = 2
GENERATOR.REACTOR_STATUS.MELTDOWN = 3

GENERATOR.status = GENERATOR.REACTOR_STATUS.OPERATIONAL

GENERATOR.powerOutput = 0
GENERATOR.MAX_POWER_OUTPUT = 10

GENERATOR.coolingPower = 0
GENERATOR.MAX_COOLING_POWER = 10

GENERATOR.heat = 0
GENERATOR.MAX_HEAT = 10
GENERATOR.HEAT_INTERVAL = 5

function GENERATOR:GetStatus()
    return self.status
end

function GENERATOR:GetPowerOutput()
    return self.powerOutput
end

function GENERATOR:GetMaxPowerOutput()
    return self.MAX_POWER_OUTPUT
end

function GENERATOR:GetCoolingPower()
    return self.coolingPower
end

function GENERATOR:GetMaxCoolingPower()
    return self.MAX_COOLING_POWER
end

function GENERATOR:GetHeat()
    return self.heat
end

function GENERATOR:GetMaxHeat()
    return self.MAX_HEAT
end

SWS.LoadGenerator(GENERATOR)