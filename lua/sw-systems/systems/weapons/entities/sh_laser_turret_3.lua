SWS = SWS or {}
SWS.Systems = SWS.Systems or {}
SWS.Systems.Weapons = SWS.Systems.Weapons or {}

local className = "sws_weapon_laser_turret_3"

ENT = {}
ENT.Base = "sws_weapon_base"
ENT.Type = "anim"
ENT.ClassName = className

ENT.PrintName = "Laser Turret 3"
ENT.Author = "List-Scripts"
ENT.Category = SWS.CATEGORY_PREFIX.."Weapons"
ENT.Spawnable = true

ENT.Model = "models/props/starwars/weapons/hoth_turret4.mdl"
ENT.HP = 5000

ENT.SmokeFXConfig = {
    {pos = Vector(0, 0, 70)},
}
ENT.SparkFXConfig = {
    {pos = Vector(0, 0, 70), direction = function() return Vector(0, 0, 0) end},
}


function ENT:Destroy() end

function ENT:DamageFX() end


scripted_ents.Register(ENT, className)