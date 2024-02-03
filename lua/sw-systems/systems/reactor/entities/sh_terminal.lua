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
    
        local phys = self:GetPhysicsObject()
    
        if phys:IsValid() then
            phys:Wake()
        end
    end
end

if CLIENT then
    local BACKGROUND_COLOR = Color(21, 28, 59)
    local MAIN_COLOR = Color(202, 245, 255)
    local GREEN_COLOR = Color(75, 247, 98)
    local RED_COLOR = Color(255, 62, 36)
    local ORANGE_COLOR = Color(255, 167, 36)
    local GRAY_COLOR = Color(181, 188, 162)

    local COOLANT_SCREEN = Material("sw-systems/reactor1.png")
    local HEAT_SCREEN = Material("sw-systems/reactor2.png")
    local POWER_SCREEN = Material("sw-systems/reactor3.png")
    local MELTDOWN_SCREEN = Material("sw-systems/reactor4.png")

    local STATUS_NAMING = {}
    STATUS_NAMING[SWS.ENUM.REACTOR_STATUS.OPERATIONAL] = "OPERATIONAL"
    STATUS_NAMING[SWS.ENUM.REACTOR_STATUS.MELTDOWN] = "MELTDOWN"


    local function drawPowerScreen(ent, x, y)
        -- draw background ---------------------------------------------------------
        surface.SetMaterial(POWER_SCREEN)
        if SWS.Reactor:GetStatus() == SWS.ENUM.REACTOR_STATUS.MELTDOWN then 
            surface.SetMaterial(MELTDOWN_SCREEN)
        end
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(x, y, 1000, 800)

        -- draw text ---------------------------------------------------------------
        draw.SpacedText("REACTOR STATUS", adraw.xFont("!Montserrat-Bold@70"), x-3, y+10, MAIN_COLOR, 20)
        draw.SpacedText("REACTOR STATUS", adraw.xFont("!Aurebesh@25"), x, y+90, MAIN_COLOR, 20)

        if SWS.Reactor:GetStatus() == SWS.ENUM.REACTOR_STATUS.MELTDOWN then
            draw.SimpleText(STATUS_NAMING[SWS.Reactor:GetStatus()], adraw.xFont("!Montserrat@80"), x+738, y+180, RED_COLOR, TEXT_ALIGN_RIGHT)
        else
            draw.SimpleText(STATUS_NAMING[SWS.Reactor:GetStatus()], adraw.xFont("!Montserrat@80"), x+738, y+180, MAIN_COLOR, TEXT_ALIGN_RIGHT)
        end
        

        draw.SimpleText("FUEL USAGE", adraw.xFont("!Aurebesh@40"), x+1000, y+360, MAIN_COLOR, TEXT_ALIGN_RIGHT)
        draw.SimpleText("COMING SOON", adraw.xFont("!Aurebesh@40"), x+1000, y+430, MAIN_COLOR, TEXT_ALIGN_RIGHT)

        draw.SpacedText("POWER OUTPUT", adraw.xFont("!Aurebesh@15"), x, y+530, MAIN_COLOR, 15)
        draw.SpacedText("POWER OUTPUT", adraw.xFont("!Montserrat-Bold@50"), x-3, y+550, MAIN_COLOR, 10)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(GREEN_COLOR)
        
        local pos = x+15
        for i=1, SWS.Reactor:GetPowerOutput() do
            surface.DrawRect(pos, y+616, 45, 137)
            pos = pos + 71.8
        end
    end

    local function drawCoolantScreen(ent, x, y)
        -- draw background ---------------------------------------------------------
        surface.SetMaterial(COOLANT_SCREEN)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(x, y, 480, 380)

        -- draw text ---------------------------------------------------------------
        draw.SpacedText("COOLANT STATUS", adraw.xFont("!Montserrat-Bold@30"), x-2, y+10, MAIN_COLOR, 10)
        draw.SpacedText("COOLANT STATUS", adraw.xFont("!Aurebesh@10"), x, y+45, MAIN_COLOR, 10)

        draw.SpacedText("COOLANT LEVEL", adraw.xFont("!Aurebesh@10"), x, y+225, MAIN_COLOR, 10)
        draw.SpacedText("COOLANT LEVEL", adraw.xFont("!Montserrat-Bold@30"), x-2, y+240, MAIN_COLOR, 10)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(MAIN_COLOR)
        
        local pos = x+8
        for i=1, SWS.Reactor:GetCoolingPower() do
            surface.DrawRect(pos, y+278, 24, 76)
            pos = pos + 39.6
        end
    end

    local function drawHeatScreen(ent, x, y)
        -- draw background ---------------------------------------------------------
        surface.SetMaterial(HEAT_SCREEN)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(x, y, 480, 380)

        -- draw text ---------------------------------------------------------------
        draw.SpacedText("HEAT STATUS", adraw.xFont("!Montserrat-Bold@30"), x-2, y+10, MAIN_COLOR, 10)
        draw.SpacedText("HEAT STATUS", adraw.xFont("!Aurebesh@10"), x, y+45, MAIN_COLOR, 10)

        draw.SpacedText("HEAT LEVEL", adraw.xFont("!Aurebesh@10"), x, y+225, MAIN_COLOR, 10)
        draw.SpacedText("HEAT LEVEL", adraw.xFont("!Montserrat-Bold@30"), x-2, y+240, MAIN_COLOR, 10)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(RED_COLOR)
        
        local pos = x+8
        for i=1, SWS.Reactor:GetHeat() do
            surface.DrawRect(pos, y+278, 24, 76)
            pos = pos + 39.6
        end
    end

    function ENT:DrawTranslucent(flags)
        self:Draw( flags )
    
        if not SWS.Reactor then return end
    
        if adraw.Entity3D2D(self, Vector(2.15, 0, 45.7), Angle(0,90,61.5), 0.01) then
            -- power screen --------------------------------------------------------
            draw.RoundedBox(160, 275, 0, 1200, 1050, BACKGROUND_COLOR)

            drawPowerScreen(self, 390, 125)
            
            adraw.End3D2D()
        end

        if adraw.Entity3D2D(self, Vector(1.95, 0, 45.1), Angle(0,90,61.5), 0.01) then
            -- coolant screen -------------------------------------------------------
            draw.RoundedBox(80, -1355, 0, 580, 480, BACKGROUND_COLOR)
            drawCoolantScreen(self, -1305, 50)

            -- heat screen -----------------------------------------------------------
            draw.RoundedBox(80, -650, 0, 580, 480, BACKGROUND_COLOR)
            drawHeatScreen(self, -600, 50)

            adraw.End3D2D()
        end

        if adraw.Entity3D2D(self, Vector(11.5, -13.8, 33.3), Angle(0, 90, 15), 0.01) then
            --draw.RoundedBox(0, 0, 0, 2600, 800, BACKGROUND_COLOR)

            draw.SpacedText("COOLANT CONTROL", adraw.xFont("!Montserrat-Bold@120"), 0-60, 0-320, GRAY_COLOR, 15)

            if adraw.xTextButton("+", adraw.xFont("!Montserrat-Bold@100"), 160, 0-10, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Reactor:SetCoolingPower(SWS.Reactor:GetCoolingPower()+1)
            end

            if adraw.xTextButton("-", adraw.xFont("!Montserrat-Bold@100"), 160, 120, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Reactor:SetCoolingPower(SWS.Reactor:GetCoolingPower()-1)
            end

            draw.SpacedText("POWER CONTROL", adraw.xFont("!Montserrat-Bold@120"), 1600, 0-320, GRAY_COLOR, 15)

            if adraw.xTextButton("+", adraw.xFont("!Montserrat-Bold@100"), 1675, 0, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Reactor:SetPowerOutput(SWS.Reactor:GetPowerOutput()+1)
            end

            if adraw.xTextButton("-", adraw.xFont("!Montserrat-Bold@100"), 1675, 140, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Reactor:SetPowerOutput(SWS.Reactor:GetPowerOutput()-1)
            end

            if adraw.xTextButton("SHUTDOWN", adraw.xFont("!Montserrat-Bold@90"), 1435, 610, 520, 220, 10, ORANGE_COLOR, RED_COLOR, ORANGE_COLOR) then
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