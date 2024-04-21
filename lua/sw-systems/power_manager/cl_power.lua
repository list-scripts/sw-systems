SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}
SWS.Power = SWS.Power or {}

net.Receive("SWS.Power.SyncData", function(len, ply)
    SWS.Power.totalPower = net.ReadUInt(8)
    SWS.Power.freePower = net.ReadUInt(8)

    SWS.Power.powerProvider = util.JSONToTable(net.ReadString())
    SWS.Power.activeSystems = util.JSONToTable(net.ReadString())
end)

net.Receive("SWS.Power.UpdateSystem", function(len, ply)
    local index = net.ReadUInt(8)
    local system = util.JSONToTable(net.ReadString())
    SWS.Power.activeSystems[index] = table.Copy(system)
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
    local system = util.JSONToTable(net.ReadString())
    table.insert(SWS.Power.activeSystems, table.Copy(system))
end)

net.Receive("SWS.Power.UnregisterSystem", function(len, ply)
    local index = net.ReadUInt(8)
    table.remove(SWS.Power.activeSystems, index)
end)