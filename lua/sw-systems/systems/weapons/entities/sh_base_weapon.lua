SWS = SWS or {}
SWS.Systems = SWS.Systems or {}
SWS.Systems.Weapons = SWS.Systems.Weapons or {}

local className = "sws_weapon_base"

ENT = {}
ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.ClassName = className

ENT.PrintName = "Base Weapon"
ENT.Author = "List-Scripts"
ENT.Category = SWS.CATEGORY_PREFIX.."Weapons"
ENT.Spawnable = false
ENT.IsEmplacement = true

if CLIENT then
    ENT.Icon = Material("sw-systems/icons/systems/weapons/turbolaser_icon.png")
end

ENT.Model = "models/props/starwars/weapons/hoth_turret2.mdl"
ENT.HP = 100

ENT.SmokeFXConfig = {}
ENT.SmokeTime = 0
ENT.SparkFXConfig = {}
ENT.SparkTime = 0

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "IsDestroyed")

    if SERVER then
        self:SetIsDestroyed(false)
    end
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
    
        local phys = self:GetPhysicsObject()
    
        if phys:IsValid() then
            phys:Wake()
        end

        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end

        self:SetMaxHealth(self.HP)
        self:SetHealth(self.HP)

        self:addToRepairDatabase()

        self:PostInitialize()
    end

    function ENT:PostInitialize() end
    function ENT:Destroy() end
    function ENT:DamageFX() end
    function ENT:IsDestroyed() return self:GetIsDestroyed() end

    function ENT:OnTakeDamage(dmg)
        self:SetHealth(math.Clamp(self:Health() - dmg:GetDamage(), 0, self:GetMaxHealth()))

        if self:Health() <= 0 and not self:IsDestroyed() then
            self:SetIsDestroyed(true)
            self:Destroy()
        end
    end

    function ENT:Repair()
        if self:Health() >= self:GetMaxHealth() then return false end
        if self:IsDestroyed() then self:SetIsDestroyed(false) end

        self:SetHealth(math.Clamp(self:Health() + self:GetMaxHealth()*0.2, 0, self:GetMaxHealth()))
        return true
    end

    function ENT:SmokeFX()
        if table.IsEmpty(self.SmokeFXConfig) then return end

        if self.SmokeTime < CurTime() then
            for _, data in ipairs(self.SmokeFXConfig) do
                local effectPos = self:LocalToWorld(data.pos)
                local effectData = EffectData()
                effectData:SetOrigin( effectPos )
                util.Effect( "sws_smoke_effect", effectData )
            end
            self.SmokeTime = CurTime() + 0.25
        end
    end

    function ENT:SparkFX()
        if table.IsEmpty(self.SparkFXConfig) then return end

        if self.SparkTime < CurTime() then
            for _, data in ipairs(self.SparkFXConfig) do
                local effectPos = self:LocalToWorld(data.pos)
                local effectData = EffectData()
                effectData:SetOrigin(effectPos)
                effectData:SetScale(math.Rand(1, 2))
                effectData:SetMagnitude(math.Rand(1, 3))
                effectData:SetRadius(math.Rand(1, 2))
                effectData:SetNormal(data:direction())
                util.Effect("Sparks", effectData)

                EmitSound("ambient/energy/spark"..math.random(1, 6)..".wav", effectPos, 75, 100, 1, CHAN_AUTO)
            end
            self.SparkTime = CurTime() + math.Rand(0.5, 5)
        end
    end

    function ENT:Think()
        if self:IsDestroyed() then self:DamageFX() end
        if self:Health() / self:GetMaxHealth() <= 0.2 then self:SmokeFX() end
        if self:Health() / self:GetMaxHealth() <= 0.5 then self:SparkFX() end

        self:NextThink(CurTime()+0.1)
        return true
    end

    ///////////////////////////
    // Fusion Cutter Support //
    ///////////////////////////

    repairDatabase = repairDatabase or {}

    function ENT:addToRepairDatabase()
        if repairDatabase[self:GetClass()] then return end

        repairDatabase[self:GetClass()] = function(fusionCutter, ent, trace)
            return ent:Repair()
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end



scripted_ents.Register(ENT, className)