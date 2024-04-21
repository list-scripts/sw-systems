SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}

local load_queue = {}

hook.Add("PlayerInitialSpawn", "SWS.PlayerLoad", function(ply)
	load_queue[ply] = true
end)

hook.Add("SetupMove", "SWS.PlayerLoad", function(ply, _, cmd)
	if load_queue[ply] and not cmd:IsForced() then
		load_queue[ply] = nil

		hook.Run("SWS.PlayerLoaded", ply)
	end
end)