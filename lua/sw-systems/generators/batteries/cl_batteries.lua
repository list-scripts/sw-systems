SWS = SWS or {}

local GENERATOR = {}
GENERATOR.IDENTIFIER = "Batteries"

GENERATOR.ICON = Material("sw-systems/icons/generators/batteries.png", "noclamp smooth")

function GENERATOR:Initialize()
    
end

SWS.LoadGenerator(GENERATOR)