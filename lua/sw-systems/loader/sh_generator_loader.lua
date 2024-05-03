SWS = SWS or {}
SWS.Generators = SWS.Generators or {}

SWS.Generators.directory = SWS.directory.."/generators"

local loadQueue = {}
local firstLoad = true

function SWS.LoadGenerator(GENERATOR)
    loadQueue[GENERATOR.IDENTIFIER] = loadQueue[GENERATOR.IDENTIFIER] or {}
    table.Merge(loadQueue[GENERATOR.IDENTIFIER], GENERATOR)
end

SWS.includeDir(SWS.Generators.directory, true)

for _, GENERATOR in pairs(loadQueue) do
    GENERATOR.NAME = GENERATOR.NAME or "Unnamed Generator"

    SWS.Generators[GENERATOR.IDENTIFIER] = table.Copy(GENERATOR)
    GENERATOR = SWS.Generators[GENERATOR.IDENTIFIER]

    GENERATOR.LOADED = true
    GENERATOR:Initialize()
    firstLoad = false
    
    SWS.includeDir(SWS.Generators.directory.."/"..string.lower(GENERATOR.IDENTIFIER).."/entities", false)
end