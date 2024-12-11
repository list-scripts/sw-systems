SWS = SWS or {}

local adraw = adraw

local className = "sws_weapons_terminal"

ENT = {}
ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.ClassName = className

ENT.PrintName = "Weapons Terminal"
ENT.Author = "List-Scripts"
ENT.Category = SWS.CATEGORY_PREFIX.."Weapons"
ENT.Spawnable = true

if SERVER then 
    function ENT:Initialize()
        self:SetModel("models/lordtrilobite/starwars/isd/imp_console_large01.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetSkin(3)
        self:SetSubMaterial(4, "sw-systems/weapons terminal/weapon_status")
        self:SetSubMaterial(5, "sw-systems/weapons terminal/emplacements")
    
        local phys = self:GetPhysicsObject()
    
        if phys:IsValid() then
            phys:Wake()
        end
    end
end

if CLIENT then
    surface.CreateFont("SWS.Weapons.Aurebesh80", {
        font = "Aurebesh",
        size = 80,
        weight = 500,
        antialias = false,
        shadow = false
    })

    surface.CreateFont("SWS.Weapons.Montserrat-Bold70", {
        font = "Montserrat Bold",
        size = 70,
        weight = 500,
        antialias = false,
        shadow = false
    })

    surface.CreateFont("SWS.Weapons.Montserrat-Bold90", {
        font = "Montserrat Bold",
        size = 90,
        weight = 500,
        antialias = false,
        shadow = false
    })
    
    surface.CreateFont("SWS.Weapons.Montserrat-Bold50", {
        font = "Montserrat Bold",
        size = 50,
        weight = 500,
        antialias = false,
        shadow = false
    })

    surface.CreateFont("SWS.Weapons.Montserrat-Bold_HUD", {
        font = "Montserrat Bold",
        size = ScreenScale(10),
        weight = 500,
        antialias = false,
        shadow = false
    })

    local emplacements = {}
    local totalEmplacements = 0
    local damagedEmplacements = 0
    local destroyedEmplacements = 0
    local functionalEmplacements = 0

    ENT.selectedEntity = nil

    function ENT:Initialize()
        timer.Create("SWS.Weapons.Terminal.Update", 1, 0, function()
            damagedEmplacements = 0
            destroyedEmplacements = 0
            functionalEmplacements = 0

            for _, emplacement in ipairs(SWS.Systems.Weapons.emplacements) do
                if emplacement:Health() == emplacement:GetMaxHealth() then
                    functionalEmplacements = functionalEmplacements + 1
                elseif emplacement:Health() <= 0 then
                    destroyedEmplacements = destroyedEmplacements + 1
                else
                    damagedEmplacements = damagedEmplacements + 1
                end
            end

            totalEmplacements = table.Count(SWS.Systems.Weapons.emplacements)

            emplacements = table.Copy(SWS.Systems.Weapons.emplacements)
            table.sort(emplacements, function(a, b)
                return a:Health()/a:GetMaxHealth() < b:Health()/b:GetMaxHealth()
            end)
        end)
    end

    local BACKGROUND_COLOR = Color(21, 28, 59)
    local MAIN_COLOR = Color(176, 238, 252)
    local GREEN_COLOR = Color(75, 247, 98)
    local BLUE_COLOR = Color(104, 227, 255)
    local RED_COLOR = Color(255, 62, 36)
    local ORANGE_COLOR = Color(255, 167, 36)
    local GRAY_COLOR = Color(181, 188, 162)

    local function drawPowerScreen(ent, x, y)
        -- draw damage amount ------------------------------------------------------
        draw.SimpleText("EMPLACEMENTS", "SWS.Weapons.Montserrat-Bold50", x+50, y+180, MAIN_COLOR)
        draw.RoundedBox(0, x+50, y+240, 320, 4, MAIN_COLOR)
        draw.SimpleText(totalEmplacements.." total", "SWS.Weapons.Montserrat-Bold50", x+50, y+250, MAIN_COLOR)
        draw.SimpleText(functionalEmplacements.." functional", "SWS.Weapons.Montserrat-Bold50", x+50, y+300, GREEN_COLOR)
        draw.SimpleText(damagedEmplacements.." damaged", "SWS.Weapons.Montserrat-Bold50", x+50, y+350, ORANGE_COLOR)
        draw.SimpleText(destroyedEmplacements.." destroyed", "SWS.Weapons.Montserrat-Bold50", x+50, y+400, RED_COLOR)
        
        -- draw text ---------------------------------------------------------------
        if SWS.Systems.Weapons:GetPower() > 0 then
            draw.SimpleText("WEAPONS ONLINE", "SWS.Weapons.Montserrat-Bold50", x+1000, y+332, GREEN_COLOR, TEXT_ALIGN_RIGHT)
        else
            draw.SimpleText("WEAPONS OFFLINE", "SWS.Weapons.Montserrat-Bold50", x+1000, y+332, RED_COLOR, TEXT_ALIGN_RIGHT)
        end

        draw.SimpleText(SWS.Systems.Weapons:GetPower(), "SWS.Weapons.Aurebesh80", x+738, y+600, MAIN_COLOR)
        draw.SimpleText(SWS.Systems.Weapons:GetMaxPower(), "SWS.Weapons.Aurebesh80", x+738, y+680, MAIN_COLOR)

        -- draw bars ----------------------------------------------------------------
        surface.SetDrawColor(GREEN_COLOR)
        
        local pos = x
        for i=1, SWS.Systems.Weapons:GetPower() do
            surface.DrawRect(pos, y+622, 45, 137)
            pos = pos + 73.8
        end
    end

    local ICON_SIZE = 128
    local LARGE_ICON_SIZE = 330
    local ICON_PADDING = 20
    local MAX_COL = 6
    local MAX_ROW = 3
    local START_Y = 380
    local START_X = 70

    local function drawEmplacementsScreen(ent, x, y)
        local emplacementCount = #emplacements
        local rows = math.ceil(emplacementCount / MAX_COL)
        local cols = math.min(emplacementCount, MAX_COL)

        local x_pos = x + START_X
        local y_pos = y + START_Y

        local counter = 0
        for _, emplacement in ipairs(emplacements) do
            if counter / MAX_COL >= MAX_ROW then continue end
            if counter >= MAX_COL*MAX_ROW-1 then 
                draw.SimpleText("+"..emplacementCount-counter, "SWS.Weapons.Montserrat-Bold90", x_pos + ICON_SIZE*0.45, y_pos + ICON_SIZE*0.45, MAIN_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                continue 
            end
            local healthPercent = emplacement:Health() / emplacement:GetMaxHealth()
            if adraw.xSolidButton(x_pos, y_pos, ICON_SIZE, ICON_SIZE, Color(0,0,0,0), BACKGROUND_COLOR, GRAY_COLOR) then
                ent.selectedEntity = emplacement
            end
            surface.SetMaterial(emplacement.Icon)
            if healthPercent <= 0 then
                surface.SetDrawColor(RED_COLOR)
            else
                surface.SetDrawColor(MAIN_COLOR)
            end
            surface.DrawTexturedRect(x_pos, y_pos, ICON_SIZE, ICON_SIZE)
            
            render.SetStencilEnable( true )

            render.ClearStencil()

            render.SetStencilTestMask( 255 )
            render.SetStencilWriteMask( 255 )

            render.SetStencilPassOperation( STENCILOPERATION_KEEP )
            render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

            render.SetStencilReferenceValue( 9 )
            render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

            draw.RoundedBox( 0, x_pos, y_pos + ICON_SIZE * (1-healthPercent), ICON_SIZE, ICON_SIZE, color_white )

            render.SetStencilFailOperation( STENCILOPERATION_KEEP )
            render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

            if healthPercent <= 0.5 then
                surface.SetDrawColor(ORANGE_COLOR)
            else
                surface.SetDrawColor(GREEN_COLOR)
            end
            surface.DrawTexturedRect(x_pos, y_pos, ICON_SIZE, ICON_SIZE)

            render.SetStencilEnable( false )

            x_pos = x_pos + ICON_SIZE + ICON_PADDING
            counter = counter + 1
            if counter%MAX_COL == 0 then
                x_pos = x + START_X
                y_pos = y_pos + ICON_SIZE + ICON_PADDING
            end
        end
    end

    local function drawInspectionScreen(ent, x, y)
        local emplacement = ent.selectedEntity
        local healthPercent = emplacement:Health() / emplacement:GetMaxHealth()
        surface.SetMaterial(emplacement.Icon)
        if healthPercent <= 0 then
            surface.SetDrawColor(RED_COLOR)
        else
            surface.SetDrawColor(MAIN_COLOR)
        end
        
        surface.DrawTexturedRect(x+START_X, y+330, LARGE_ICON_SIZE, LARGE_ICON_SIZE)
        
        render.SetStencilEnable( true )

        render.ClearStencil()

        render.SetStencilTestMask( 255 )
        render.SetStencilWriteMask( 255 )

        render.SetStencilPassOperation( STENCILOPERATION_KEEP )
        render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

        render.SetStencilReferenceValue( 9 )
        render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

        draw.RoundedBox( 0, x+START_X, y+330 + LARGE_ICON_SIZE * (1-healthPercent), LARGE_ICON_SIZE, LARGE_ICON_SIZE, color_white )

        render.SetStencilFailOperation( STENCILOPERATION_KEEP )
        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

        if healthPercent <= 0.5 then
            surface.SetDrawColor(ORANGE_COLOR)
        else
            surface.SetDrawColor(GREEN_COLOR)
        end
        surface.DrawTexturedRect(x+START_X, y+330, LARGE_ICON_SIZE, LARGE_ICON_SIZE)

        render.SetStencilEnable( false )

        -- draw information --------------------------------------------------------
        surface.SetFont("SWS.Weapons.Montserrat-Bold70")
        local textWidth, textHeight = surface.GetTextSize(emplacement.PrintName)
        draw.SimpleText(emplacement.PrintName, "SWS.Weapons.Montserrat-Bold70", x+START_X+LARGE_ICON_SIZE+50, y+310, MAIN_COLOR)

        draw.RoundedBox(0, x+START_X+LARGE_ICON_SIZE+50, y+400, textWidth, 6, MAIN_COLOR)

        draw.SimpleText(emplacement.WeaponType, "SWS.Weapons.Montserrat-Bold50", x+START_X+LARGE_ICON_SIZE+50, y+420, MAIN_COLOR)
        draw.SimpleText(emplacement.TargetType, "SWS.Weapons.Montserrat-Bold50", x+START_X+LARGE_ICON_SIZE+50, y+470, MAIN_COLOR)


        local color = GREEN_COLOR
        if healthPercent <= 0.5 then
            color = ORANGE_COLOR
        elseif healthPercent <= 0 then
            color = RED_COLOR
        end
        draw.SimpleText(math.Round(healthPercent*100, 1).."% Integrity", "SWS.Weapons.Montserrat-Bold50", x+START_X+LARGE_ICON_SIZE+50, y+520, color)

        if adraw.xTextButton("RETURN", "SWS.Weapons.Montserrat-Bold90", x+START_X, y+740, 330, 120, 10, MAIN_COLOR, ORANGE_COLOR, RED_COLOR) then
            ent.selectedEntity = nil
        end

        if adraw.xTextButton("LOCATE", "SWS.Weapons.Montserrat-Bold90", x+START_X+570, y+740, 330, 120, 10, MAIN_COLOR, ORANGE_COLOR, RED_COLOR) then
            hook.Add("HUDPaint", "SWS.Weapons.Terminal.Find"..emplacement:EntIndex(), function()
                local pos = emplacement:LocalToWorld(emplacement:OBBCenter())
                local pos2D = pos:ToScreen()
                local distance = math.Round(LocalPlayer():GetPos():Distance(emplacement:GetPos())* 0.01905, 1)
                local icon = emplacement.Icon
                local iconSize = ScrH()*0.05
                surface.SetMaterial(icon)
                surface.SetDrawColor(GREEN_COLOR)
                surface.DrawTexturedRect(pos2D.x-iconSize/2, pos2D.y-iconSize/2, iconSize, iconSize)
                draw.SimpleText(distance.." m", "SWS.Weapons.Montserrat-Bold_HUD", pos2D.x, pos2D.y+iconSize*0.5, GREEN_COLOR, TEXT_ALIGN_CENTER)
            end)

            timer.Create("SWS.Weapons.Terminal.Find"..emplacement:EntIndex(), 5, 1, function()
                hook.Remove("HUDPaint", "SWS.Weapons.Terminal.Find"..emplacement:EntIndex())
            end)
        end
    end

    function ENT:DrawTranslucent(flags)
        self:Draw( flags )
    
        if not SWS.Systems.Weapons then return end
    
        if adraw.Entity3D2D(self, Vector(2.15, 27, 45.7), Angle(0,90,61.5), 0.01) then
            -- power screen --------------------------------------------------------
            drawPowerScreen(self, 33, 125)

            adraw.End3D2D()
        end

        if adraw.Entity3D2D(self, Vector(2.15, -35.6, 45.7), Angle(0,90,61.5), 0.01) then
            -- emplacement screen --------------------------------------------------------
            if self.selectedEntity then
                drawInspectionScreen(self, 0, 0)
            else
                drawEmplacementsScreen(self, 0, 0)
            end

            adraw.End3D2D()
        end
    end

    function ENT:Draw()
        self:DrawModel()
    end
end

scripted_ents.Register(ENT, className)