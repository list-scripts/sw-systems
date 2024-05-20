-- serverside chat.AddText()
-- made by senfauge (https://github.com/senfauge)
-- idea and some help by Star (https://github.com/StarLight-Oliver)

if SERVER then
    local meta_ply = FindMetaTable( "Player" )
    util.AddNetworkString("chat.ChatPrint")

    function meta_ply:AddText(tbl)
        tbl = istable(tbl) and tbl or {tbl}
        local newTbl = {}
        local lastColor = Color(255,255,255)
        for i,v in ipairs(tbl) do
            lastColor = IsColor(v) and v or lastColor
            if IsEntity(v) and v:IsPlayer() then
                table.insert(newTbl, team.GetColor(v:Team()))
                table.insert(newTbl, v:Name())
                table.insert(newTbl, lastColor)
                continue
            end
            table.insert(newTbl, v)
        end
    
        net.Start("chat.ChatPrint")
            net.WriteTable(newTbl)
        net.Send(self)
    end
    
    local chat  = chat or {}
    function chat.ChatBroadcast(tbl)
        tbl = istable(tbl) and tbl or {tbl}
        local newTbl = {}
        local lastColor = Color(255,255,255)
        for i,v in ipairs(tbl) do
            lastColor = IsColor(v) and v or lastColor
            if IsEntity(v) and v:IsPlayer() then
                table.insert(newTbl, team.GetColor(v:Team()))
                table.insert(newTbl, v:Name())
                table.insert(newTbl, lastColor)
                continue
            end
            table.insert(newTbl, v)
        end
    
        net.Start("chat.ChatPrint")
            net.WriteTable(newTbl)
        net.Broadcast()
    end
elseif CLIENT then
    net.Receive("chat.ChatPrint", function()
        chat.AddText(unpack(net.ReadTable()))
    end)
end