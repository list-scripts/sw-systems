SWS = SWS or {}
SWS.Power = SWS.Power or {}

net.Receive("SWS.Power.SyncData", function(len, ply)
    SWS.Power.totalPower = net.ReadUInt(8)
    SWS.Power.freePower = net.ReadUInt(8)

    local generatorIdentifiers = util.JSONToTable(net.ReadString())
    for _, identifier in pairs(generatorIdentifiers) do
        table.insert(SWS.Power.activeGenerators, SWS.Generators[identifier])
    end

    local systemIdentifiers = util.JSONToTable(net.ReadString())
    for _, identifier in pairs(systemIdentifiers) do
        table.insert(SWS.Power.activeSystems, SWS.Systems[identifier])
    end
end)

net.Receive("SWS.Power.UpdateSystem", function(len, ply)
    local index = net.ReadUInt(8)
    local newPower = net.ReadUInt(8)
    SWS.Power.activeSystems[index].power = newPower
end)

net.Receive("SWS.Power.UpdatePower", function(len, ply)
    SWS.Power.totalPower = net.ReadUInt(8)
    SWS.Power.freePower = net.ReadUInt(8)
end)

net.Receive("SWS.Power.SwapSystems", function(len, ply)
    local index1 = net.ReadUInt(8)
    local index2 = net.ReadUInt(8)

    local temp = table.Copy(SWS.Power.activeSystems[index1])
    SWS.Power.activeSystems[index1] = table.Copy(SWS.Power.activeSystems[index2])
    SWS.Power.activeSystems[index2] = table.Copy(temp)
end)

net.Receive("SWS.Power.RegisterSystem", function(len, ply)
    local identifier = net.ReadString()
    table.insert(SWS.Power.activeSystems, SWS.Systems[identifier])
end)

net.Receive("SWS.Power.UnregisterSystem", function(len, ply)
    local index = net.ReadUInt(8)
    table.remove(SWS.Power.activeSystems, index)
end)

net.Receive("SWS.Power.RegisterGenerator", function(len, ply)
    local identifier = net.ReadString()
    PrintTable(SWS.Generators[identifier])
    table.insert(SWS.Power.activeGenerators, SWS.Generators[identifier])
end)

net.Receive("SWS.Power.UnregisterGenerator", function(len, ply)
    local index = net.ReadUInt(8)
    table.remove(SWS.Power.activeGenerators, index)
end)