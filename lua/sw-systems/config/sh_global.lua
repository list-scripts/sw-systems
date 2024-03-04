SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}

SWS.ENTITY_CATEGORY = "[SW: Systems] "

-- the minimum range for entities to be interactible
SWS.ENTITY_RANGE = 8000

SWS.ADMIN_GROUPS = {}
SWS.ADMIN_GROUPS["superadmin"] = true
SWS.ADMIN_GROUPS["admin"] = true
SWS.ADMIN_GROUPS["owner"] = true

-- do your own permission checks here if needed
function SWS.IsAdmin(ply)
    return SWS.ADMIN_GROUPS[ply:GetUserGroup()]
end