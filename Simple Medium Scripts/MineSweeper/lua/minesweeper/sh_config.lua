--[[
	Configuration game
--]]

local draw_color = Color --> TODO: Client micro-optimizate DELETE XD :)

MineSweeper.Config = {
	Console_Command = "cl_play_minesweeper";
	Chat_Command = "/playminesweeper";
   
    Difficulties = {  
	{
		name = "Easy",
		x = 9,
		y = 9,
		bombs = 10,
		color = draw_color(0, 255, 0)
	},

	{
		name = "Medium",
		x = 15,
		y = 15,
		bombs = 25,
		color = draw_color(255, 251, 0)
	},

	{
		name = "Hard",
		x = 20,
		y = 20,
		bombs = 50,
		color = draw_color(250, 121, 1)
	},

	{
		name = "Crazy",
		x = 30,
		y = 23,
		bombs = 100,
		color = draw_color(255, 0, 0)
	},
};

	TextColors = {
	 [1] = draw_color(0, 128, 0),
	 [2] = draw_color(0, 0, 255),
	 [3] = draw_color(255, 0, 0),
	 [4] = draw_color(255, 165, 0),
	 [5] = draw_color(128, 0, 128),
	 [6] = draw_color(72, 61, 139),
	 [7] = draw_color(188, 143, 143),
	 [8] = draw_color(123, 104, 238),
   };
}