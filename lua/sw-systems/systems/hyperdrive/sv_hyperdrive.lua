SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Hyperdrive"

function SYSTEM:Initialize()
    if SWU then 
        SWS.Power:RegisterSystem(self)
    else
        hook.Add("SWU.Loaded", "SWS.Hyperdrive.Register", function()
            SWS.Power:RegisterSystem(self)
            hook.Remove("SWU.Loaded", "SWS.Hyperdrive.Register")
        end)
    end
end

function SYSTEM:HandlePowerChange(newPower)
    local modifier = self.MODIFIER_PER_POWER[newPower] or 0
    self:ChangeHyperspaceSpeed(modifier)

    if newPower == 0 then
        SWU.Controller:SetCanJumpIntoHyperspace(false)
        if SWU.Controller:IsInHyperspace() then
            local lever = ents.FindByClass("swu_lever_hyperspace")[1]
            if IsValid(lever) then
                lever:AbortJump()
            end
        end
    else
        SWU.Controller:SetCanJumpIntoHyperspace(true)
    end
end

function SYSTEM:ChangeHyperspaceSpeed(newModifier)
    local oldModifier = (SWU.Configuration:GetConVar("swu_external_hyperspace_speed_modifier"):GetFloat() or 1)
    SWU.Configuration:GetConVar("swu_external_hyperspace_speed_modifier"):SetString(newModifier)

    local oldAcceleration = SWU.GlobalConfig.hyperspaceAcceleration
    SWU.GlobalConfig.hyperspaceAcceleration = SWU.GlobalConfig.hyperspaceAcceleration / oldModifier * newModifier

    net.Start("SWU_ChangeHyperspaceAcceleration")
        net.WriteVector(SWU.GlobalConfig.hyperspaceAcceleration)
    net.Broadcast()

    hook.Run("SWU_RecalculateFlightTime", oldAcceleration, SWU.GlobalConfig.hyperspaceAcceleration)
end

SWS.LoadSystem(SYSTEM)