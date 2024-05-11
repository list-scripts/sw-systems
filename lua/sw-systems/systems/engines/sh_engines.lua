SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Engines"

SYSTEM.NAME = "Engines"
SYSTEM.MAX_POWER = 5
SYSTEM.power = 0
SYSTEM.PREFERRED_INITIAL_POWER = 3

SYSTEM.ACCELERATION_PER_POWER = {
    [0] = 0,
    [1] = 20,
    [2] = 40,
    [3] = 60,
    [4] = 80,
    [5] = 100
}

SWS.LoadSystem(SYSTEM)