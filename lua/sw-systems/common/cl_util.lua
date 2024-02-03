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

    for k,v in ipairs(string.ToTable(text)) do
        local w = surface.GetTextSize(v)
        draw.SimpleText(v, font, x+pos, y, color)

        pos = pos + w + spacing
    end
end

