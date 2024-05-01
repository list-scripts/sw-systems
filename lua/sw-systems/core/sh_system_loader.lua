SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Systems = SWS.Systems or {}

local loadQueue = {}
local firstLoad = true

function SWS.LoadSystem(SYSTEM)
    loadQueue[SYSTEM.IDENTIFIER] = loadQueue[SYSTEM.IDENTIFIER] or {}
    table.Merge(loadQueue[SYSTEM.IDENTIFIER], SYSTEM)
end

SWS.includeDir("systems")

for _, SYSTEM in pairs(loadQueue) do
    SYSTEM.NAME = SYSTEM.NAME or "Unnamed System"
    SYSTEM.MAX_POWER = SYSTEM.MAX_POWER or 0

    SWS.Systems[SYSTEM.IDENTIFIER] = table.Copy(SYSTEM)
    SYSTEM = SWS.Systems[SYSTEM.IDENTIFIER]

    SYSTEM.LOADED = true
    SYSTEM:Initialize()
    firstLoad = false
end