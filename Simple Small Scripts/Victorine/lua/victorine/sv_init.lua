util.AddNetworkString("Victorine")

local function RusFix(s, t)
	if type(s) == "string" && type(t) == "string" then
		local m, n, d = utf8.len(s), utf8.len(t), {}

		for i = 0, m do
			d[i] = {
				[0] = i
			}
		end

		for j = 1, n do
			d[0][j] = j
		end

		for i = 1, m do
			for j = 1, n do
				local cost = utf8.sub(s, i, i) == utf8.sub(t, j, j) && 0 || 1
				d[i][j] = math.min(d[ i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost)
			end
		end

		return d[m][n]
	end
end

function Victorine:SendMessage(type, msg)
	net.Start("Victorine")
	net.WriteUInt(type, 3)
	net.WriteType(msg || false)
	net.Broadcast()
end

local answer = false

local function GenerateQuestion()
	local transfer_question = Victorine.Config.Questions[math.random(#Victorine.Config.Questions)]
	answer = {unpack(transfer_question, 2)}
	Victorine:SendMessage(1, transfer_question[1])
end

local function GenerateMath()
	local transfer_math = Victorine.Config.Mathematics[math.random(#Victorine.Config.Mathematics)]
	local rnd_min, rnd_max, rnd_round = unpack(transfer_math, 2, 4)
	local formula_func = transfer_math[5]
	local formula = transfer_math[1]
	local rnd = {}

	formula = string.gsub(formula, "[a-z]", function(char)
		rnd[char] = math.Round(math.Rand(rnd_min, rnd_max), rnd_round)
		return tostring(rnd[char])
	end)

	answer = formula_func(rnd)

	Victorine:SendMessage(2, formula)
end

local function HandleAnswer(ply, text)
	if !answer then return end

	if istable(answer) then
		for k, v in next, answer do
			if RusFix(v, text) >= math.floor(utf8.len(v) / 3.5) then
				continue
			end
			return true
		end

	elseif answer == tonumber(text) then
		return true
	end
end

timer.Create("Victorine", Victorine.Config.Time, 0, function()
	if math.random() <= 0.5 then
		GenerateMath()
	else
		GenerateQuestion()
	end

	timer.Create("VictorineStop", Victorine.Config.StopTime, 1, function()
		Victorine:SendMessage(4)
		answer = false
	end)
end)

hook.Add("PlayerSay", "SayVictorine", function(ply, text)
	if HandleAnswer(ply, text) then
		Victorine:SendMessage(3, {ply})
		timer.Remove("VictorineStop")
		return ""
	end
end)