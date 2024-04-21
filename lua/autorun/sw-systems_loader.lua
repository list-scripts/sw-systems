SWS = SWS or {}
SWS.ENUM = SWS.ENUM or {}

local rootDirectory = "sw-systems"

local function AddFile( File, directory )
	local prefix = string.lower( string.Left( File, 3 ) )

	if SERVER and prefix == "sv_" then
		include( directory .. File )
		print( "[SWS] " ..directory .. File )
	elseif prefix == "sh_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
		end
		include( directory .. File )
		print( "[SWS] " ..directory .. File )
	elseif prefix == "cl_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
		elseif CLIENT then
			include( directory .. File )
            print( "[SWS] " ..directory .. File )
		end
	end
end

local function IncludeDir( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		IncludeDir( directory .. v )
	end
end

IncludeDir(rootDirectory .. "/config")
IncludeDir(rootDirectory .. "/lang")
IncludeDir(rootDirectory .. "/lib")
IncludeDir(rootDirectory .. "/core")
IncludeDir(rootDirectory .. "/power_manager")
IncludeDir(rootDirectory .. "/systems")