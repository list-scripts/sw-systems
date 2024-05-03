SWS = SWS or {}
SWS.Power = SWS.Power or {}

SWS.Power.totalPower = 0
SWS.Power.freePower = 0

SWS.Power.activeGenerators = {}
SWS.Power.activeSystems = {}

function SWS.Power:GetTotalPower()
    return SWS.Power.totalPower
end

function SWS.Power:GetFreePower()
    return SWS.Power.freePower
end

function SWS.Power:GetSystemIndexByName(name)
    for i, sys in ipairs(SWS.Power.activeSystems) do
        if sys.NAME == name then
            return i
        end
    end
end

function SWS.Power:GetSystemNameByIndex(name)
    return SWS.Power.activeSystems[index].name
end

function SWS.Power:GetSystem(identifier)
    if isstring(identifier) then
        identifier = SWS.Power:GetSystemIndexByName(identifier)
    end
    return SWS.Power.activeSystems[identifier], identifier
end

function SWS.Power:GetSystemMaxPower(identifier)
    return SWS.Power:GetSystem(identifier).MAX_POWER
end

function SWS.Power:GetSystemPower(identifier)
    return SWS.Power:GetSystem(identifier).power
end