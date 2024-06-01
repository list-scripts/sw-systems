SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Shields"

function SYSTEM:Initialize()
    SWS.Power:RegisterSystem(self)
end

function SYSTEM:HandlePowerChange(newPower, oldPower)
    
end

SWS.LoadSystem(SYSTEM)