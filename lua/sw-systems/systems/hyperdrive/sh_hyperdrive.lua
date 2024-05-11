SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Hyperdrive"

SYSTEM.NAME = "Hyperdrive"
SYSTEM.MAX_POWER = 5
SYSTEM.power = 0
SYSTEM.PREFERRED_INITIAL_POWER = 1

SYSTEM.MODIFIER_PER_POWER = {
    [0] = 0.1,
    [1] = 0.5,
    [2] = 0.75,
    [3] = 1,
    [4] = 1.25,
    [5] = 1.5
}

SWS.LoadSystem(SYSTEM)