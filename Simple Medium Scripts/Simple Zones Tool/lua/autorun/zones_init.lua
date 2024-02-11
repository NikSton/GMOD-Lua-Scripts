Zones = Zones or {}

AddCSLuaFile("zones/cl_init.lua")

if CLIENT then
	include("zones/cl_init.lua")
else
	include("zones/sv_init.lua")
end