SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Hyperdrive"

SYSTEM.NAME = "Hyperdrive"
SYSTEM.MAX_POWER = 5
SYSTEM.power = 0
SYSTEM.PREFERRED_INITIAL_POWER = 1

SYSTEM.MODIFIER_PER_POWER = {
    [0] = 0.01,
    [1] = 0.2,
    [2] = 0.4,
    [3] = 0.6,
    [4] = 0.8,
    [5] = 1
}

SWS.LoadSystem(SYSTEM)