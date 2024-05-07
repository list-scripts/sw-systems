SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Hyperdrive"

function SYSTEM:Initialize()
    SWS.Power:RegisterSystem(self)
end

function SYSTEM:HandlePowerChange(newPower)
    
end

SWS.LoadSystem(SYSTEM)