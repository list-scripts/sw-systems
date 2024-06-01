SWS = SWS or {}
SWS.Systems = SWS.Systems or {}

SWS.Systems.directory = SWS.directory.."/systems"

/////////////////
// System Meta //
/////////////////

local META_SYSTEM = {}
META_SYSTEM.__index = META_SYSTEM
META_SYSTEM.LOADED = false
META_SYSTEM.IDENTIFIER = "unnamed"
META_SYSTEM.NAME = "Unnamed System"
META_SYSTEM.MAX_POWER = 0
META_SYSTEM.power = 0

function META_SYSTEM:GetName()
    return self.NAME
end

function META_SYSTEM:GetIdentifier()
    return self.IDENTIFIER
end

function META_SYSTEM:GetMaxPower()
    return self.MAX_POWER
end

function META_SYSTEM:GetPower()
    return self.power
end

function META_SYSTEM:HandlePowerChange(newPower, oldPower)
    
end

function META_SYSTEM:SetPower(newPower)
    local oldPower = self:GetPower()
    self.power = math.Clamp(newPower, 0, self:GetMaxPower())
    self:HandlePowerChange(self:GetPower(), oldPower)
    hook.Run("SWS."..self:GetName()..".PowerChange", newPower, oldPower)
end

////////////////////
// System Loading //
////////////////////

local loadQueue = {}
local firstLoad = true

function SWS.LoadSystem(SYSTEM)
    loadQueue[SYSTEM.IDENTIFIER] = loadQueue[SYSTEM.IDENTIFIER] or {}
    table.Merge(loadQueue[SYSTEM.IDENTIFIER], SYSTEM)
end

SWS.includeDir(SWS.Systems.directory, {entities = true})

for _, SYSTEM in pairs(loadQueue) do
    setmetatable(SYSTEM, META_SYSTEM)

    SWS.Systems[SYSTEM.IDENTIFIER] = table.Copy(SYSTEM)
    SYSTEM = SWS.Systems[SYSTEM.IDENTIFIER]

    SYSTEM.LOADED = true
    SYSTEM:Initialize()
    firstLoad = false

    SWS.includeDir(SWS.Systems.directory.."/"..string.lower(SYSTEM.IDENTIFIER).."/entities")
end