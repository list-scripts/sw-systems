SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Reactor = SWS.Reactor or {}

///////////
// Debug //
///////////

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
        addText("status", SWS.Reactor.status)
        addText("powerOutput", SWS.Reactor.powerOutput, SWS.Reactor.MAX_POWER_OUTPUT)
        addText("coolingPower", SWS.Reactor.coolingPower, SWS.Reactor.MAX_COOLING_POWER)
        addText("heat", SWS.Reactor.heat, SWS.Reactor.MAX_HEAT)
    addText("└────────────────────┘")

    lastDraw = CurTime() + UPDATE_TIME
end)

////////////////
// Networking //
////////////////

net.Receive("SWS.Reactor.Status", function(len, ply)
    SWS.Reactor.status = net.ReadUInt(4)
end)

net.Receive("SWS.Reactor.Power", function(len, ply)
    SWS.Reactor.powerOutput = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.Cooling", function(len, ply)
    SWS.Reactor.coolingPower = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.Heat", function(len, ply)
    SWS.Reactor.heat = net.ReadUInt(8)
end)

net.Receive("SWS.Reactor.SyncData", function(len, ply)
    SWS.Reactor.status = net.ReadUInt(4)
    SWS.Reactor.powerOutput = net.ReadUInt(8)
    SWS.Reactor.coolingPower = net.ReadUInt(8)
    SWS.Reactor.heat = net.ReadUInt(8)
end)

////////////
// Setter //
////////////

function SWS.Reactor:SetPowerOutput(number)
    net.Start("SWS.Reactor.Power")
        net.WriteUInt(math.Clamp(number, 0, SWS.Reactor.MAX_POWER_OUTPUT), 8)
    net.SendToServer()
end

function SWS.Reactor:SetCoolingPower(number)
    net.Start("SWS.Reactor.Cooling")
        net.WriteUInt(math.Clamp(number, 0, SWS.Reactor.MAX_COOLING_POWER), 8)
    net.SendToServer()
end