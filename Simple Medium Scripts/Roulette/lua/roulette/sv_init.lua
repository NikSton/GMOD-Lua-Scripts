--[[
    DO NOT TOUCH IF YOU DO NOT KNOW THE FUNCTIONS!!!!
--]]

util.AddNetworkString("Roulette_Start")
util.AddNetworkString("Roulette_Chat")

local function SendMessage(ply, msgtext)
    net.Start("Roulette_Chat")
    net.WriteUInt(msgtext, 2)
    net.Send(ply)
end

hook.Add("PlayerSay", "Roulette.ChatText", function(ply, text)
    if text == Roulette.Config.Command_Spin then
    	if ply.Roulette_Use_Command and ply.Roulette_Use_Command > CurTime() - Roulette.Config.Cooldown then
    		SendMessage(ply, 1)
    		return ""
    	end
		
    	ply.Roulette_Use_Command = CurTime()

        local target = ply:GetEyeTrace().Entity
        if !IsValid(target) or not target:IsPlayer() then
            SendMessage(ply, 2)
            return ""
        end
		
        local Winner_Chance = math.random() < 0.5
        local Num_Cards = math.random(50, 500)

        net.Start("Roulette_Start")
        net.WriteBool(Winner_Chance)
        net.WriteUInt(Num_Cards, 9)
        net.WriteString(target:Name())
        net.Send(ply)

        net.Start("Roulette_Start")
        net.WriteBool(not Winner_Chance)
        net.WriteUInt(Num_Cards, 9)
        net.WriteString(ply:Name())
        net.Send(target)
        return ""
    end
end)