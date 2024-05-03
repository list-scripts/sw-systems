SWS = SWS or {}

SWS.directory = "sw-systems"
local rootDirectory = SWS.directory

local function AddFile( File, directory )
	local prefix = string.lower( string.Left( File, 3 ) )

	if SERVER and prefix == "sv_" then
		print( "[SWS] " ..directory .. File )
		include( directory .. File )
	elseif prefix == "sh_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
		end
		print( "[SWS] " ..directory .. File )
		include( directory .. File )
	elseif prefix == "cl_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
		elseif CLIENT then
            print( "[SWS] " ..directory .. File )
			include( directory .. File )
		end
	end
end

function SWS.includeDir( directory, ignoredDirectories )
	directory = directory .. "/"

	ignoredDirectories = ignoredDirectories or {}

	local tempDirectories = string.Explode( "/", directory )
	local lastDirectory = tempDirectories[#tempDirectories - 1]

	if ignoredDirectories[lastDirectory] then return end

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		SWS.includeDir( directory .. v, ignoredDirectories)
	end
end

SWS.includeDir(rootDirectory .. "/config")
SWS.includeDir(rootDirectory .. "/lang")
SWS.includeDir(rootDirectory .. "/lib")
SWS.includeDir(rootDirectory .. "/core", {loader = true})
SWS.includeDir(rootDirectory .. "/core/loader")