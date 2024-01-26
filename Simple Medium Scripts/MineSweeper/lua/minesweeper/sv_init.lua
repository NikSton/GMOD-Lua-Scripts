--[[
    Simple SERVERSIDE XD :)
--]]

util.AddNetworkString("MineSweeper_RunGame")
hook.Add("PlayerSay", "MineSweeper.ChatText", function(ply, text)
if text == MineSweeper.Config.Chat_Command then
        net.Start("MineSweeper_RunGame")
        net.Send(ply)
		 return ""
	 end
end)