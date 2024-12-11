SWS = SWS or {}
SWS.Systems = SWS.Systems or {}
SWS.Systems.Weapons = SWS.Systems.Weapons or {}

local className = "sws_weapon_xx10_turret"

ENT = {}
ENT.Base = "sws_weapon_base"
ENT.Type = "anim"
ENT.ClassName = className

ENT.PrintName = "XX-10 Tower"
ENT.WeaponType = "Turbolaser"
ENT.TargetType = "Anti-Ship"
ENT.Author = "List-Scripts"
ENT.Category = SWS.CATEGORY_PREFIX.."Weapons"
ENT.Spawnable = true

if CLIENT then
    ENT.Icon = Material("sw-systems/icons/systems/weapons/turbolaser_icon.png")
end

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

SWS.Systems.Weapons.classIsEmplacement[className] = true
scripted_ents.Register(ENT, className)