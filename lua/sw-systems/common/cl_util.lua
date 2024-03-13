SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}

-- maybe use this later, dunno
--[[
local function drawVerticalStripedRect(x, y, w, h, color1, color2, thickness)
    surface.SetDrawColor(color1)
    surface.DrawRect(x, y, w, h)

    surface.SetDrawColor(color2)
    for i=0, math.floor((h/thickness-1)*0.5) do
        surface.DrawRect(x, y + i * thickness * 2, w, thickness)
    end

    local remainder = h%thickness

    surface.DrawRect(x, y + h - remainder, w, remainder)
end

local function drawHorizontalStripedRect(x, y, w, h, color1, color2, thickness)
    surface.SetDrawColor(color1)
    surface.DrawRect(x, y, w, h)

    surface.SetDrawColor(color2)
    for i=0, math.floor((w/thickness-1)*0.5) do
        surface.DrawRect(x + i * thickness * 2, y, thickness, h)
    end

    local remainder = w%thickness

    surface.DrawRect(x + w - remainder, y, remainder, h)
end]]

hook.Add("HUDPaint", "Test", function()
    --drawVerticalStripedRect(100, 100, 60, 200, Color(255, 255, 255), Color(0, 0, 0), 4)
    --drawHorizontalStripedRect(200, 100, 200, 60, Color(255, 255, 255), Color(0, 0, 0), 4)
end)

function draw.SpacedText(text, font, x, y, color, spacing)
    surface.SetFont(font)
    local pos = 0

    for k, char in ipairs(string.ToTable(text)) do
        local w = surface.GetTextSize(char)
        draw.SimpleText(char, font, x+pos, y, color)

        pos = pos + w + spacing
    end
end

///////////
// Debug //
///////////

-- thanks to Menschlich for this code

local lastDraw = 0
local UPDATE_TIME = 1

local i = 0

local function addText(title, val1, val2)
    if not val1 then
        debugoverlay.ScreenText(0.01, 0.2 + i * 0.015, title, UPDATE_TIME, color_white)
        i = i + 1
        return
    end

    debugoverlay.ScreenText(0.01, 0.2 + i * 0.015, "\t" .. title .. ":", UPDATE_TIME, color_white)

    if val2 then
        debugoverlay.ScreenText(0.08, 0.2 + i * 0.015, val1 .. " / " .. val2, UPDATE_TIME, color_white)
    else
        debugoverlay.ScreenText(0.08, 0.2 + i * 0.015, val1, UPDATE_TIME, color_white)
    end
    i = i + 1
end

local devConvar = GetConVar("developer")

hook.Add("Think", "SWS.Reactor.Debug", function()
    if not devConvar:GetBool() then return end
    if lastDraw > CurTime() then return end

    local ply = LocalPlayer()

    i = 0

    addText("┌──── Realtime Stats ────┐")
        addText("power", SWS.Power.freePower, SWS.Power.totalPower)
        addText("\t---------------------------")
        addText("status", SWS.Reactor.status)
        addText("powerOutput", SWS.Reactor.powerOutput, SWS.Reactor.MAX_POWER_OUTPUT)
        addText("coolingPower", SWS.Reactor.coolingPower, SWS.Reactor.MAX_COOLING_POWER)
        addText("heat", SWS.Reactor.heat, SWS.Reactor.MAX_HEAT)
    addText("└────────────────────┘")

    lastDraw = CurTime() + UPDATE_TIME
end)
