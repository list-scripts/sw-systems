SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Power = SWS.Power or {}

SWS.Power.totalPower = 0
SWS.Power.freePower = 0

SWS.Power.powerProvider = {}
SWS.Power.systems = {}

function SWS.Power:GetTotalPower()
    return SWS.Power.totalPower
end

function SWS.Power:GetFreePower()
    return SWS.Power.freePower
end

function SWS.Power:GetSystemIndexByName(name)
    for i, sys in ipairs(SWS.Power.systems) do
        if sys.name == name then
            return i
        end
    end
end

function SWS.Power:GetSystemNameByIndex(name)
    return SWS.Power.systems[index].name
end

function SWS.Power:GetSystem(identifier)
    if isstring(identifier) then
        identifier = SWS.Power:GetSystemIndexByName(identifier)
    end
    return SWS.Power.systems[identifier], identifier
end

function SWS.Power:GetSystemMaxPower(identifier)
    return SWS.Power:GetSystem(identifier).maxPower
end

function SWS.Power:GetSystemPower(identifier)
    return SWS.Power:GetSystem(identifier).power
end

function SWS.Power:GetSystemUpdateFunc(identifier)
    return SWS.Power:GetSystem(identifier).update
end