SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Weapons"

SYSTEM.NAME = "Weapons"
SYSTEM.MAX_POWER = 5
SYSTEM.power = 0
SYSTEM.PREFERRED_INITIAL_POWER = 1
SYSTEM.classIsEmplacement = {}
SYSTEM.emplacements = {}

function SYSTEM:InitializeHooks()
    hook.Add("OnEntityCreated", "SWS.Weapons.OnEmplacementSpawned", function(ent)
        if not IsValid(ent) then return end
        if not SWS.Systems.Weapons:IsEmplacement(ent) then return end
    
        table.insert(SWS.Systems.Weapons.emplacements, ent)
    end)

    hook.Add("EntityRemoved", "SWS.Weapons.OnEmplacementRemoved", function(ent)
        if not IsValid(ent) then return end
        if not SWS.Systems.Weapons:IsEmplacement(ent) then return end
    
        table.remove(SWS.Systems.Weapons.emplacements, table.KeyFromValue(SWS.Systems.Weapons.emplacements, ent))
    end)
end

function SYSTEM:IsEmplacement(ent)
    if self.classIsEmplacement[ent:GetClass()] then
        return true
    end
end

SWS.LoadSystem(SYSTEM)