Victorine = Victorine or {}
include("victorine/sh_config.lua")
if SERVER then
	AddCSLuaFile("victorine/sh_config.lua")
	AddCSLuaFile("victorine/cl_init.lua")
	include("victorine/sv_init.lua")
else
	include("victorine/cl_init.lua")
end