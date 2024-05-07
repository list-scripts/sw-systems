SWS = SWS or {}

local GENERATOR = {}
GENERATOR.IDENTIFIER = "Batteries"

GENERATOR.NAME = "Batteries"

GENERATOR.powerOutput = 2
GENERATOR.MAX_POWER_OUTPUT = 10

function GENERATOR:GetPowerOutput()
    return self.powerOutput
end

function GENERATOR:GetMaxPowerOutput()
    return self.MAX_POWER_OUTPUT
end

SWS.LoadGenerator(GENERATOR)