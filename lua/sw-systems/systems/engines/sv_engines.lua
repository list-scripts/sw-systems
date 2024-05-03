SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Engines"

function SYSTEM:Initialize()
    SWS.Power:RegisterSystem(self)
end

function SYSTEM:HandlePowerChange(newpower)
    
end

SWS.LoadSystem(SYSTEM)