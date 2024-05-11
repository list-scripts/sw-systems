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
        --self:SetAngles(self:GetAngles() + Angle(0,-90,0))
    end
end

if CLIENT then

    surface.CreateFont("SWS.Power.Aurebesh15", {
        font = "Aurebesh",
        size = 15,
        weight = 500,
        antialias = false,
        shadow = false
    })

    surface.CreateFont("SWS.Power.Aurebesh30", {
        font = "Aurebesh",
        size = 30,
        weight = 500,
        antialias = false,
        shadow = false
    })

    surface.CreateFont("SWS.Power.Bold50", {
        font = "Montserrat Bold",
        size = 50,
        weight = 500,
        antialias = false,
        shadow = false
    })

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
    
        self.selectedSystem = 1
    end
    
    function ENT:ScrW()
        return self.scrW * 10
    end
    
    function ENT:ScrH()
        return self.scrH * 10
    end
    
    local BACKGROUND_COLOR = Color(21, 28, 59)
    local MAIN_COLOR = Color(176, 238, 252)
    local GREEN_COLOR = Color(57, 252, 135)
    local GRAY_COLOR = Color(124, 133, 130)
    local ORANGE_COLOR = Color(255, 167, 36)

    local BAR_WIDTH = 50
    local BAR_HEIGHT = 15
    local BAR_PADDING = 10

    local X_PADDING = 30
    local Y_PADDING = 40

    local BORDER_WIDTH = 5

    local POWER_HEIGHT = 70
    local MAIN_HEIGHT = 50
    local FOOTER_PADDING = 5
    local FOOTER_HEIGHT = 15
    local LINE_WIDTH = 2
    local LINE_PADDING = 5

    local width = nil
    local height = nil

    local KEY_WIDTH = 260
    local KEY_HEIGHT = 108
    local KEY_PADDING = 10
    local BUTTON_WIDTH = (KEY_WIDTH - KEY_PADDING*2) /3

    local function drawGenerators(x, y)
        local x_pos = x
        for index, generator in ipairs(SWS.Power.activeGenerators) do
            local color = generator:GetPowerOutput() > 0 and MAIN_COLOR or GRAY_COLOR
            surface.SetDrawColor(color)
            surface.SetMaterial(generator.ICON)
            surface.DrawTexturedRect(x_pos, y, BAR_WIDTH, BAR_WIDTH)
            x_pos = x_pos + BAR_WIDTH + BAR_PADDING
        end
        return x_pos
    end

    local function drawPower(x, y)
        local x_pos = x
        local totalPower = SWS.Power:GetTotalPower()
        local freePower = SWS.Power:GetFreePower()

        -- draw the first vertical spacer line
        surface.SetDrawColor(MAIN_COLOR)
        surface.DrawRect(x_pos, y, LINE_WIDTH, POWER_HEIGHT)
        draw.SimpleText("0", "SWS.Power.Aurebesh15", x_pos + LINE_PADDING + 1, y + POWER_HEIGHT - 1, MAIN_COLOR, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        x_pos = x_pos + LINE_WIDTH + LINE_PADDING

        for i = 0, totalPower - 1 do
            local color = freePower > i and GREEN_COLOR or GRAY_COLOR
            surface.SetDrawColor(color)
            surface.DrawRect(x_pos, y, BAR_HEIGHT, BAR_WIDTH)
            x_pos = x_pos + BAR_HEIGHT + LINE_PADDING

            surface.SetDrawColor(MAIN_COLOR)
            local lineHeight = MAIN_HEIGHT
            local isFifth = (i-4) % 5 == 0
            local isLast = i  == totalPower - 1
            if isFifth and not isLast then
                lineHeight = POWER_HEIGHT
                draw.SimpleText(i+1, "SWS.Power.Aurebesh15", x_pos + LINE_PADDING + 1, y + POWER_HEIGHT - 1, MAIN_COLOR, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            elseif isLast then
                lineHeight = POWER_HEIGHT
            end

            surface.DrawRect(x_pos, y, LINE_WIDTH, lineHeight)
            x_pos = x_pos + LINE_WIDTH + LINE_PADDING
        end

        draw.SimpleText(freePower, "SWS.Power.Aurebesh30", x_pos, y-9, MAIN_COLOR, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(totalPower, "SWS.Power.Aurebesh30", x_pos, y + POWER_HEIGHT - 1, MAIN_COLOR, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    function ENT:drawSystem(index, x, y, system)
        surface.SetDrawColor(MAIN_COLOR)
        surface.SetMaterial(system.ICON)
        surface.DrawTexturedRect(x, y - BAR_WIDTH, BAR_WIDTH, BAR_WIDTH)
        y_pos = y - BAR_WIDTH - BAR_PADDING - BAR_HEIGHT

        local power = system.power or 0
        local maxPower = system.MAX_POWER or 0

        for i = 0, maxPower - 1 do
            local color = power > i and GREEN_COLOR or GRAY_COLOR
            surface.SetDrawColor(color)
            surface.DrawRect(x, y_pos, BAR_WIDTH, BAR_HEIGHT)
            y_pos = y_pos - BAR_HEIGHT - BAR_PADDING
        end

        local top_y = y_pos + BAR_HEIGHT
        local systemHeight = y-y_pos

        if index == self.selectedSystem then
            surface.SetDrawColor(MAIN_COLOR)
            surface.DrawOutlinedRect(x - BAR_PADDING, top_y, BAR_WIDTH + BAR_PADDING * 2, systemHeight, BORDER_WIDTH)
        else
            if adraw.xButton(x - BAR_PADDING, top_y, BAR_WIDTH + BAR_PADDING * 2, systemHeight, BORDER_WIDTH, GRAY_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                self.selectedSystem = index
            end
        end
    end

    function ENT:DrawTranslucent(flags)
        self:Draw( flags )

        width = width or self:ScrW()
        height = height or self:ScrH()

        -- screen area
        if adraw.Entity3D2D(self, self.tl, Angle(0,180,90), 0.1) then
            local last_x = drawGenerators(0, height-MAIN_HEIGHT)
            drawPower(last_x, height-MAIN_HEIGHT)

            surface.SetDrawColor(MAIN_COLOR)
            surface.DrawRect(0, height-POWER_HEIGHT, width, LINE_WIDTH)

            local x_pos = X_PADDING * 0.5 - BORDER_WIDTH
            for index, system in ipairs(SWS.Power.activeSystems) do
                self:drawSystem(index, x_pos, height - Y_PADDING-POWER_HEIGHT, system)
                x_pos = x_pos + BAR_WIDTH + X_PADDING
            end

            adraw.End3D2D()
        end

        -- keyboard area
        if adraw.Entity3D2D(self, self.keytl, Angle(0,180,33), 0.1) then

            if adraw.xTextButton("<", "SWS.Power.Bold50", KEY_PADDING, KEY_PADDING, BUTTON_WIDTH, KEY_HEIGHT, BORDER_WIDTH, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                net.Start("SWS.Power.IncreaseSystemPriority")
                    net.WriteUInt(self.selectedSystem, 8)
                net.SendToServer()
                self.selectedSystem = math.Clamp(self.selectedSystem - 1, 1, #SWS.Power.activeSystems)
            end

            if adraw.xTextButton(">", "SWS.Power.Bold50", KEY_PADDING+KEY_WIDTH-BUTTON_WIDTH, KEY_PADDING, BUTTON_WIDTH, KEY_HEIGHT, BORDER_WIDTH, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                net.Start("SWS.Power.DecreaseSystemPriority")
                    net.WriteUInt(self.selectedSystem, 8)
                net.SendToServer()
                self.selectedSystem = math.Clamp(self.selectedSystem + 1, 1, #SWS.Power.activeSystems)
            end

            if adraw.xTextButton("+", "SWS.Power.Bold50", BUTTON_WIDTH + KEY_PADDING*2, KEY_PADDING, BUTTON_WIDTH, (KEY_HEIGHT-KEY_PADDING)*0.5, BORDER_WIDTH, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                net.Start("SWS.Power.IncreasePower")
                    net.WriteUInt(self.selectedSystem, 8)
                net.SendToServer()
            end

            if adraw.xTextButton("-", "SWS.Power.Bold50", BUTTON_WIDTH + KEY_PADDING*2, KEY_PADDING*2+(KEY_HEIGHT-KEY_PADDING)*0.5, BUTTON_WIDTH, (KEY_HEIGHT-KEY_PADDING)*0.5, BORDER_WIDTH, MAIN_COLOR, ORANGE_COLOR, MAIN_COLOR) then
                net.Start("SWS.Power.DecreasePower")
                    net.WriteUInt(self.selectedSystem, 8)
                net.SendToServer()
            end

            adraw.End3D2D()
        end

    end

    function ENT:Draw()
        self:DrawModel()
    end
end

scripted_ents.Register(ENT, "sws_power_terminal")