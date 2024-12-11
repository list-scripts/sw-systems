SWS = SWS or {}
SWS.Systems = SWS.Systems or {}
SWS.Systems.Weapons = SWS.Systems.Weapons or {}

local className = "sws_weapon_df9_battery_a"

ENT = {}
ENT.Base = "sws_weapon_base"
ENT.Type = "anim"
ENT.ClassName = className

ENT.PrintName = "DF.9 Battery A"
ENT.WeaponType = "Laser Cannon"
ENT.TargetType = "Anti-Infantry"
ENT.Author = "List-Scripts"
ENT.Category = SWS.CATEGORY_PREFIX.."Weapons"
ENT.Spawnable = true

if CLIENT then
    ENT.Icon = Material("sw-systems/icons/systems/weapons/laserturret_icon.png")
end

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

SWS.Systems.Weapons.classIsEmplacement[className] = true
scripted_ents.Register(ENT, className)