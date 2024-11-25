SWS = SWS or {}
SWS.Systems = SWS.Systems or {}
SWS.Systems.Weapons = SWS.Systems.Weapons or {}

local className = "sws_weapon_turbolaser"

ENT = {}
ENT.Base = "sws_weapon_base"
ENT.Type = "anim"
ENT.ClassName = className

ENT.PrintName = "Turbolaser"
ENT.Author = "List-Scripts"
ENT.Category = SWS.CATEGORY_PREFIX.."Weapons"
ENT.Spawnable = true

ENT.Model = "models/props/starwars/weapons/imperial_turbolaser.mdl"
ENT.HP = 20000

ENT.SmokeFXConfig = {
    {pos = Vector(0, 0, 350)},
}

ENT.SparkFXConfig = {
    {pos = Vector(-210, -30, 350), direction = function() return Vector(1, 0, math.Rand(0, 1)) end},
}


function ENT:Destroy() end

function ENT:DamageFX() end


scripted_ents.Register(ENT, className)