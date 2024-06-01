SWS = SWS or {}

if not (game.GetMap() == "rp_venator_extensive_v1_4") then return end

local venatorWeaponsEnabled = true

local venatorSeatNames = {
    "TLSeat1",
    "TLSeat2",
    "TLSeat3",
    "TLSeat4",
    "venatorMaserSeat1",
    "TLSeat10",
}

local venatorTurretNames = {
    "TLUi1",
    "TLUi2",
    "TLUi3",
    "TLUi4",
    "venatorMaserUI1",
    "venatorMaserUI2",
}

local function setVenatorWeaponsEnabled(setEnabled)
    if setEnabled then
        if updateCannonPos == nil then return end
        hook.Add("Think", "UpdateCannonPos", updateCannonPos)

        for i,v in ipairs(venatorSeatNames) do
            local seat = ents.FindByName(v)[1]
            local driver = seat:GetDriver()
            if not IsValid(driver) then continue end
            driver:ExitVehicle()
            timer.Simple(0.1, function()
                driver:EnterVehicle(seat)
            end)
        end


        venatorWeaponsEnabled = true
    else
        if updateCannonPos == nil then
            updateCannonPos = hook.GetTable()["Think"]["UpdateCannonPos"]
        end
        hook.Remove("Think", "UpdateCannonPos")

        for i=1,5 do
            local turret = ents.FindByName(venatorTurretNames[i])[1]
            local seat = ents.FindByName(venatorSeatNames[i])[1]
            if not (IsValid(turret) and IsValid(seat)) then continue end
            if seat:GetDriver() == NULL then continue end
            turret:Fire("Deactivate")
        end
        venatorWeaponsEnabled = false
    end

    venatorWeaponsEnabled = setEnabled
end

hook.Add("PlayerEnteredVehicle", "SWS.Weapons.DeactivateOnEnter", function(ply, vehicle)
    if not (IsValid(ply) and IsValid(vehicle)) then return end
    if venatorWeaponsEnabled then return end
    if table.HasValue(venatorSeatNames, vehicle:GetName()) then
        local turret = ents.FindByName(venatorTurretNames[table.KeyFromValue(venatorSeatNames, vehicle:GetName())])[1]
        if IsValid(turret) then
            turret:Fire("deactivate")
        end
    end
end)

hook.Add("SWS.Weapons.PowerChange", "SWS.Weapons.VenatorWeapons", function(newPower, oldPower)
    if newPower == 0 then
        setVenatorWeaponsEnabled(false)
    elseif not venatorWeaponsEnabled then
        setVenatorWeaponsEnabled(true)
    end
end)

