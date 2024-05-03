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

local ignoredDirectories = {
	["entities"] = true,
}

function SWS.includeDir( directory, shouldIgnore )
	directory = directory .. "/"

	local tempDirectories = string.Explode( "/", directory )
	local lastDirectory = tempDirectories[#tempDirectories - 1]

	if shouldIgnore and ignoredDirectories[lastDirectory] then return end

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		SWS.includeDir( directory .. v, shouldIgnore)
	end
end

IncludeDir(rootDirectory .. "/config")
IncludeDir(rootDirectory .. "/lang")
IncludeDir(rootDirectory .. "/lib")
IncludeDir(rootDirectory .. "/core")
IncludeDir(rootDirectory .. "/loader")