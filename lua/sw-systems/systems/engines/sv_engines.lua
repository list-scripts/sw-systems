SWS = SWS or {}

local SYSTEM = {}
SYSTEM.IDENTIFIER = "Engines"

function SYSTEM:Initialize()
    if SWU then 
        if SWU.Controller then
            SWS.Power:RegisterSystem(self)
        end
    else
        hook.Add("SWU.Loaded", "SWS.Engines.Register", function()
            SWS.Power:RegisterSystem(self)
            hook.Remove("SWU.Loaded", "SWS.Engines.Register")
        end)
    end
end

function SYSTEM:HandlePowerChange(newPower)
    local acceleration = self.ACCELERATION_PER_POWER[newPower] or 0
    SWU.Controller:SetTargetShipAccelerationLimit(acceleration)

    local targetAcceleration = SWU.Controller:GetTargetShipAcceleration()
    if targetAcceleration > acceleration then
        SWU.Controller:SetTargetShipAcceleration(acceleration)
    end

    if newPower == 0 then
        SWU.Controller:SetTargetShipAngles(SWU.Controller:GetShipAngles())
    end
end


hook.Add( "OnEntityCreated", "SWS.Engines.SetAcceleration", function( ent )
	if ( ent:GetClass() == "swu_controller" ) then
        timer.Simple(1, function()
            local acceleration = SWS.Systems.Engines.ACCELERATION_PER_POWER[SWS.Systems.Engines.Power] or 0
            SWU.Controller:SetTargetShipAccelerationLimit(acceleration)
        end)
	end
end )

SWS.LoadSystem(SYSTEM)