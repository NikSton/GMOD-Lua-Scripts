MineSweeper = MineSweeper or {}
include("minesweeper/sh_config.lua")
if SERVER then
	AddCSLuaFile("minesweeper/sh_config.lua")
	AddCSLuaFile("minesweeper/cl_init.lua")
	include("minesweeper/sv_init.lua")
else
	include("minesweeper/cl_init.lua")
end