SWS = SWS or {}
SWS.Generators = SWS.Generators or {}

SWS.generatorDirectory = SWS.directory.."/generators"

///////////////////////
// Generator Loading //
///////////////////////

local META_GENERATOR = {}
META_GENERATOR.__index = META_GENERATOR
META_GENERATOR.LOADED = false
META_GENERATOR.IDENTIFIER = "unnamed"
META_GENERATOR.NAME = "Unnamed Generator"
META_GENERATOR.MAX_POWER_OUTPUT = 0
META_GENERATOR.powerOutput = 0

function META_GENERATOR:GetName()
    return self.NAME
end

function META_GENERATOR:GetIdentifier()
    return self.IDENTIFIER
end

function META_GENERATOR:GetMaxPowerOutput()
    return self.MAX_POWER_OUTPUT
end

function META_GENERATOR:GetPowerOutput()
    return self.powerOutput
end

///////////////////////
// Generator Loading //
///////////////////////

local loadQueue = {}
local firstLoad = true

function SWS.LoadGenerator(GENERATOR)
    if firstLoad then
        loadQueue[GENERATOR.IDENTIFIER] = loadQueue[GENERATOR.IDENTIFIER] or {}
        table.Merge(loadQueue[GENERATOR.IDENTIFIER], GENERATOR)
    else
        table.Merge(SWS.Generators[GENERATOR.IDENTIFIER], GENERATOR)
    end
end

SWS.includeDir(SWS.generatorDirectory, {entities = true})

for _, GENERATOR in pairs(loadQueue) do
    setmetatable(GENERATOR, META_GENERATOR)

    SWS.Generators[GENERATOR.IDENTIFIER] = table.Copy(GENERATOR)
    GENERATOR = SWS.Generators[GENERATOR.IDENTIFIER]

    GENERATOR.LOADED = true
    GENERATOR:Initialize()
    firstLoad = false
    
    SWS.includeDir(SWS.generatorDirectory.."/"..string.lower(GENERATOR.IDENTIFIER).."/entities")
end