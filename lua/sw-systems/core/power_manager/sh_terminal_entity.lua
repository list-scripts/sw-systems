SWS = SWS or {}
SWS.Reactor = SWS.Reactor or {}

local adraw = adraw

ENT = {}
ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.ClassName = name

ENT.PrintName = "Power Terminal"
ENT.Author = "senfauge & Luiggi33"
ENT.Category = SWS.CATEGORY_PREFIX.."Power"
ENT.Spawnable = true

if SERVER then 
    function ENT:Initialize()
        self:SetModel("models/dolunity/swo/terminal.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    
        local phys = self:GetPhysicsObject()
    
        if phys:IsValid() then
            phys:Wake()
        end

        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
        self:SetAngles(self:GetAngles() + Angle(0,-90,0))

    end
end

if CLIENT then
    function ENT:Initialize()
        -- get screen area dimensions
        local tl, br = self:LookupAttachment("display_tl"), self:LookupAttachment("display_br")
        self.tl = self:WorldToLocal(self:GetAttachment(tl).Pos)
        self.br = self:WorldToLocal(self:GetAttachment(br).Pos)
        self.scrDim = (self.tl - self.br)
        self.scrW = self.scrDim.x
        self.scrH = self.scrDim.z
    
        -- get keyboard area dimensions
        local tl, br = self:LookupAttachment("keyboard_tl"), self:LookupAttachment("keyboard_br")
        self.keytl = self:WorldToLocal(self:GetAttachment(tl).Pos)
        self.keytlang = self:WorldToLocalAngles(self:GetAttachment(tl).Ang)
        self.keybr = self:WorldToLocal(self:GetAttachment(br).Pos)
        self.keyDim = (self.keytl - self.keybr)
        self.keyW = self.keyDim.x
        self.keyH = self.keyDim.z
    
        self.selected = nil
    end
    
    function ENT:ScrW() -- gets screen width of the entities screen
        return self.scrW * 10
    end
    
    function ENT:ScrH() -- gets screen heigth of the entities screen
        return self.scrH * 10
    end
    
    local BACKGROUND_COLOR = Color(21, 28, 59)
    local MAIN_COLOR = Color(176, 238, 252)
    local GREEN_COLOR = Color(75, 247, 98)
    local BLUE_COLOR = Color(104, 227, 255)
    local RED_COLOR = Color(255, 62, 36)
    local ORANGE_COLOR = Color(255, 167, 36)
    local GRAY_COLOR = Color(181, 188, 162)

    local START_Y = 200

    function ENT:DrawTranslucent(flags)
        self:Draw( flags )

        -- screen area
        if adraw.Entity3D2D(self, self.tl, Angle(0,180,90), 0.1) then
            surface.SetDrawColor( 255, 0, 0, 200)
			surface.DrawRect( 0, START_Y, 100, 100)
            adraw.End3D2D()
        end

        -- keyboard area
        if adraw.Entity3D2D(self, self.keytl, Angle(0,180,33), 0.1) then

            adraw.End3D2D()
        end

    end

    function ENT:Draw()
        self:DrawModel()
    end
end

scripted_ents.Register(ENT, "sws_power_terminal")