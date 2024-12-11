SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Weapons"

SYSTEM.ICON = Material("sw-systems/icons/systems/weapons.png", "noclamp smooth")

function SYSTEM:Initialize()
    self:InitializeHooks()
end

SWS.LoadSystem(SYSTEM)