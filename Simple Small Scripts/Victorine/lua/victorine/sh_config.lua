Victorine.Config = {
    Time = 60 * 15;
	StopTime = 5 * 60;
    Questions = {
		{"Who is the shaitan gmod?", "Rubat"},
		{"What programming language is gmod?", "Lua", "Glua"},
		{"What year did the game come out?", "2005"},
		{"Who is the creator of the game?", "Garry", "Newman"},
		{"What is the popular gamemode in gmod?", "DarkRP"},
	};

   Mathematics = {
		{"x + y", 100, 1000, 2, function(f) return f.x + f.y end},
		{"x - y", 100, 1000, 2, function(f) return f.x - f.y end},
		{"x * y", 10, 40, 0, function(f) return f.x * f.y end},
		{"x + y * z", 10, 30, 0, function(f) return f.x + f.y * f.z end},
	};
}