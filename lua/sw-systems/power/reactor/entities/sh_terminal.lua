SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Reactor = SWS.Reactor or {}

local adraw = adraw

ENT = {}
ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.ClassName = name

ENT.PrintName = "Reactor Terminal"
ENT.Author = "senfauge & Luiggi33"
ENT.Category = SWS.ENTITY_CATEGORY.."Reactor"
ENT.Spawnable = true

ENT.ModelPath = "models/lordtrilobite/starwars/isd/imp_console_medium03.mdl"

if SERVER then 
    function ENT:Initialize()
        self:SetModel(self.ModelPath)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetSubMaterial(0, "sw-systems/reactor terminal/imp_console_reactor_edit")
        self:SetSubMaterial(1, "sw-systems/reactor terminal/heat-screen")
        self:SetSubMaterial(2, "sw-systems/reactor terminal/coolant-screen")
        self:SetSubMaterial(3, "sw-systems/reactor terminal/power-screen")
    
        local phys = self:GetPhysicsObject()
    
        if phys:IsValid() then
            phys:Wake()
        end
    end
end

if CLIENT then
    local BACKGROUND_COLOR = Color(21, 28, 59)
    local MAIN_COLOR = Color(176, 238, 252)
    local GREEN_COLOR = Color(75, 247, 98)
    local BLUE_COLOR = Color(104, 227, 255)
    local RED_COLOR = Color(255, 62, 36)
    local ORANGE_COLOR = Color(255, 167, 36)
    local GRAY_COLOR = Color(181, 188, 162)

    local STATUS_NAMING = {}
    STATUS_NAMING[SWS.ENUM.REACTOR_STATUS.OPERATIONAL] = "OPERATIONAL"
    STATUS_NAMING[SWS.ENUM.REACTOR_STATUS.MELTDOWN] = "MELTDOWN"


    local function drawPowerScreen(ent, x, y)

        -- draw text ---------------------------------------------------------------
        if SWS.Reactor:GetStatus() == SWS.ENUM.REACTOR_STATUS.MELTDOWN then
            draw.SimpleText(STATUS_NAMING[SWS.Reactor:GetStatus()], adraw.xFont("!Montserrat@80"), x+738, y+175, RED_COLOR, TEXT_ALIGN_RIGHT)
        else
            draw.SimpleText(STATUS_NAMING[SWS.Reactor:GetStatus()], adraw.xFont("!Montserrat@80"), x+738, y+175, MAIN_COLOR, TEXT_ALIGN_RIGHT)
        end

        draw.SimpleText(SWS.Reactor:GetPowerOutput(), adraw.xFont("!Montserrat Bold@95"), x+738, y+600, MAIN_COLOR)
        draw.SimpleText(SWS.Reactor:GetMaxPowerOutput(), adraw.xFont("!Montserrat Bold@95"), x+738, y+680, MAIN_COLOR)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(GREEN_COLOR)
        
        local pos = x
        for i=1, SWS.Reactor:GetPowerOutput() do
            surface.DrawRect(pos, y+622, 45, 137)
            pos = pos + 73.8
        end
    end

    local function drawCoolantScreen(ent, x, y)

        -- draw text ---------------------------------------------------------------
        draw.SimpleText(SWS.Reactor:GetCoolingPower(), adraw.xFont("!Montserrat Bold@57"), x+414, y+255, MAIN_COLOR)
        draw.SimpleText(SWS.Reactor:GetMaxCoolingPower(), adraw.xFont("!Montserrat Bold@57"), x+414, y+305, MAIN_COLOR)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(BLUE_COLOR)
        
        local pos = x+8.5
        for i=1, SWS.Reactor:GetCoolingPower() do
            surface.DrawRect(pos, y+274, 24, 76)
            pos = pos + 40
        end
    end

    local function drawHeatScreen(ent, x, y)

        -- draw text ---------------------------------------------------------------
        draw.SimpleText(SWS.Reactor:GetHeat(), adraw.xFont("!Montserrat Bold@57"), x+414, y+255, MAIN_COLOR)
        draw.SimpleText(SWS.Reactor:GetMaxHeat(), adraw.xFont("!Montserrat Bold@57"), x+414, y+305, MAIN_COLOR)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(RED_COLOR)
        
        local pos = x+8.5
        for i=1, SWS.Reactor:GetHeat() do
            surface.DrawRect(pos, y+274, 24, 76)
            pos = pos + 40
        end
    end

    function ENT:DrawTranslucent(flags)
        self:Draw( flags )
    
        if not SWS.Reactor then return end
    
        if adraw.Entity3D2D(self, Vector(2.15, 0, 45.7), Angle(0,90,61.5), 0.01) then
            -- power screen --------------------------------------------------------
            drawPowerScreen(self, 390, 125)

            adraw.End3D2D()
        end

        if adraw.Entity3D2D(self, Vector(1.95, 0, 45.1), Angle(0,90,61.5), 0.01) then
            -- coolant screen -------------------------------------------------------
            drawCoolantScreen(self, -1305, 50)

            -- heat screen -----------------------------------------------------------
            drawHeatScreen(self, -600, 50)

            adraw.End3D2D()
        end

        if adraw.Entity3D2D(self, Vector(11.5, -13.8, 33.3), Angle(0, 90, 15), 0.01) then
            --draw.RoundedBox(0, 0, 0, 2600, 800, BACKGROUND_COLOR)

            if adraw.xTextButton("+", adraw.xFont("!Montserrat Bold@100"), 160, 0-10, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Reactor:SetCoolingPower(SWS.Reactor:GetCoolingPower()+1)
            end

            if adraw.xTextButton("-", adraw.xFont("!Montserrat Bold@100"), 160, 120, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Reactor:SetCoolingPower(SWS.Reactor:GetCoolingPower()-1)
            end

            if adraw.xTextButton("+", adraw.xFont("!Montserrat Bold@100"), 1675, 0, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Reactor:SetPowerOutput(SWS.Reactor:GetPowerOutput()+1)
            end

            if adraw.xTextButton("-", adraw.xFont("!Montserrat Bold@100"), 1675, 140, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Reactor:SetPowerOutput(SWS.Reactor:GetPowerOutput()-1)
            end

            if adraw.xTextButton("SHUTDOWN", adraw.xFont("!Montserrat Bold@90"), 1435, 610, 520, 220, 10, ORANGE_COLOR, RED_COLOR, ORANGE_COLOR) then
                SWS.Reactor:SetPowerOutput(0)
            end

            adraw.End3D2D()
        end
    end

    function ENT:Draw()
        self:DrawModel()
    end
end

scripted_ents.Register(ENT, "sws_reactor_terminal")