SWS = SWS or {}

local adraw = adraw

local className = "sws_reactor_terminal"

ENT = {}
ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.ClassName = className

ENT.PrintName = "Reactor Terminal"
ENT.Author = "List-Scripts"
ENT.Category = SWS.CATEGORY_PREFIX.."Reactor"
ENT.Spawnable = true

if SERVER then 
    function ENT:Initialize()
        self:SetModel("models/lordtrilobite/starwars/isd/imp_console_medium03.mdl")
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
    surface.CreateFont("SWS.Reactor.Aurebesh80", {
        font = "Aurebesh",
        size = 80,
        weight = 500,
        antialias = false,
        shadow = false
    })

    surface.CreateFont("SWS.Reactor.Aurebesh40", {
        font = "Aurebesh",
        size = 40,
        weight = 500,
        antialias = false,
        shadow = false
    })

    surface.CreateFont("SWS.Reactor.Montserrat-Bold130", {
        font = "Montserrat Bold",
        size = 130,
        weight = 500,
        antialias = false,
        shadow = false
    })

    surface.CreateFont("SWS.Reactor.Montserrat-Bold90", {
        font = "Montserrat Bold",
        size = 90,
        weight = 500,
        antialias = false,
        shadow = false
    })
    
    surface.CreateFont("SWS.Reactor.Montserrat80", {
        font = "Montserrat",
        size = 80,
        weight = 500,
        antialias = false,
        shadow = false
    })

    local BACKGROUND_COLOR = Color(21, 28, 59)
    local MAIN_COLOR = Color(176, 238, 252)
    local GREEN_COLOR = Color(75, 247, 98)
    local BLUE_COLOR = Color(104, 227, 255)
    local RED_COLOR = Color(255, 62, 36)
    local ORANGE_COLOR = Color(255, 167, 36)
    local GRAY_COLOR = Color(181, 188, 162)

    local STATUS_NAMING = {}
    STATUS_NAMING[SWS.Generators.Reactor.REACTOR_STATUS.OPERATIONAL] = "OPERATIONAL"
    STATUS_NAMING[SWS.Generators.Reactor.REACTOR_STATUS.MELTDOWN] = "MELTDOWN"


    local function drawPowerScreen(ent, x, y)

        -- draw text ---------------------------------------------------------------
        if SWS.Generators.Reactor:GetStatus() == SWS.Generators.Reactor.REACTOR_STATUS.MELTDOWN then
            draw.SimpleText(STATUS_NAMING[SWS.Generators.Reactor:GetStatus()], "SWS.Reactor.Montserrat80", x+738, y+175, RED_COLOR, TEXT_ALIGN_RIGHT)
        else
            draw.SimpleText(STATUS_NAMING[SWS.Generators.Reactor:GetStatus()], "SWS.Reactor.Montserrat80", x+738, y+175, MAIN_COLOR, TEXT_ALIGN_RIGHT)
        end

        draw.SimpleText(SWS.Generators.Reactor:GetPowerOutput(), "SWS.Reactor.Aurebesh80", x+738, y+600, MAIN_COLOR)
        draw.SimpleText(SWS.Generators.Reactor:GetMaxPowerOutput(), "SWS.Reactor.Aurebesh80", x+738, y+680, MAIN_COLOR)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(GREEN_COLOR)
        
        local pos = x
        for i=1, SWS.Generators.Reactor:GetPowerOutput() do
            surface.DrawRect(pos, y+622, 45, 137)
            pos = pos + 73.8
        end
    end

    local function drawCoolantScreen(ent, x, y)

        -- draw text ---------------------------------------------------------------
        draw.SimpleText(SWS.Generators.Reactor:GetCoolingPower(), "SWS.Reactor.Aurebesh40", x+414, y+265, MAIN_COLOR)
        draw.SimpleText(SWS.Generators.Reactor:GetMaxCoolingPower(), "SWS.Reactor.Aurebesh40", x+414, y+310, MAIN_COLOR)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(BLUE_COLOR)
        
        local pos = x+8.5
        for i=1, SWS.Generators.Reactor:GetCoolingPower() do
            surface.DrawRect(pos, y+274, 24, 76)
            pos = pos + 40
        end
    end

    local function drawHeatScreen(ent, x, y)

        -- draw text ---------------------------------------------------------------
        draw.SimpleText(SWS.Generators.Reactor:GetHeat(), "SWS.Reactor.Aurebesh40", x+414, y+265, MAIN_COLOR)
        draw.SimpleText(SWS.Generators.Reactor:GetMaxHeat(), "SWS.Reactor.Aurebesh40", x+414, y+310, MAIN_COLOR)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(RED_COLOR)
        
        local pos = x+8.5
        for i=1, SWS.Generators.Reactor:GetHeat() do
            surface.DrawRect(pos, y+274, 24, 76)
            pos = pos + 40
        end
    end

    function ENT:DrawTranslucent(flags)
        self:Draw( flags )
    
        if not SWS.Generators.Reactor then return end
    
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

            if adraw.xTextButton("+", "SWS.Reactor.Montserrat-Bold130", 160, 0-10, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Generators.Reactor:SetCoolingPower(SWS.Generators.Reactor:GetCoolingPower()+1)
            end

            if adraw.xTextButton("-", "SWS.Reactor.Montserrat-Bold130", 160, 120, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Generators.Reactor:SetCoolingPower(SWS.Generators.Reactor:GetCoolingPower()-1)
            end

            if adraw.xTextButton("+", "SWS.Reactor.Montserrat-Bold130", 1675, 0, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Generators.Reactor:SetPowerOutput(SWS.Generators.Reactor:GetPowerOutput()+1)
            end

            if adraw.xTextButton("-", "SWS.Reactor.Montserrat-Bold130", 1675, 140, 120, 120, 10, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                SWS.Generators.Reactor:SetPowerOutput(SWS.Generators.Reactor:GetPowerOutput()-1)
            end

            if adraw.xTextButton("SHUTDOWN", "SWS.Reactor.Montserrat-Bold90", 1435, 610, 520, 220, 10, ORANGE_COLOR, RED_COLOR, ORANGE_COLOR) then
                SWS.Generators.Reactor:SetPowerOutput(0)
            end

            adraw.End3D2D()
        end
    end

    function ENT:Draw()
        self:DrawModel()
    end
end

scripted_ents.Register(ENT, className)