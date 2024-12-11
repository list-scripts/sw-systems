SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Weapons"

function SYSTEM:Initialize()
    self:InitializeHooks()
    SWS.Power:RegisterSystem(self)
end

function SYSTEM:HandlePowerChange(newPower, oldPower)
    
end

SWS.LoadSystem(SYSTEM)