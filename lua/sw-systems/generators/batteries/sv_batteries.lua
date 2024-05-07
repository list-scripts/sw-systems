SWS = SWS or {}
SWS.Power = SWS.Power or {}

local GENERATOR = {}
GENERATOR.IDENTIFIER = "Batteries"

function GENERATOR:Initialize()
    SWS.Power:RegisterGenerator(self)
end

SWS.LoadGenerator(GENERATOR)