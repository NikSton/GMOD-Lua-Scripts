Roulette = Roulette or {}
include("roulette/sh_config.lua")
if SERVER then
	AddCSLuaFile("roulette/sh_config.lua")
	AddCSLuaFile("roulette/cl_init.lua")
	include("roulette/sv_init.lua")
else
	include("roulette/cl_init.lua")
end