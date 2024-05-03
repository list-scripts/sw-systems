SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Engines"

function SYSTEM:Initialize()
    SWS.Power:RegisterSystem(self.IDENTIFIER, self.MAX_POWER, self)
end

function SYSTEM:HandlePowerChange(newpower)
    print("Engines power changed to " .. newpower)
end

SWS.LoadSystem(SYSTEM)