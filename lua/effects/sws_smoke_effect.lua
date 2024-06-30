function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.DieTime = CurTime() + 0.4

	self:Smoke()
end

function EFFECT:Smoke()
	local emitter = ParticleEmitter( self.Pos, false )
	if not emitter then return end

	for i = 0, 3 do
		local particle = emitter:Add( "particle/smokesprites_00" .. math.random( 0, 1 ) .. math.random( 1, 6 ), self.Pos )
		if particle then
			particle:SetVelocity( Vector(math.Rand(-100, 100), math.Rand(-100, 100), 200) )
			particle:SetDieTime( math.Rand( 3, 6 ) )
			particle:SetAirResistance( 4 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 50, 100 ) )
			particle:SetEndSize( math.Rand( 300, 400 ) )
			particle:SetRoll( math.Rand( -1, 1 ) )
			particle:SetColor( 50, 50, 50 )
			particle:SetGravity( Vector( 0, 0, 50 ) )
			particle:SetCollide( false )
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	if self.DieTime < CurTime() then return false end
end

function EFFECT:Render()
end