util.AddNetworkString("zone_builder")

local function StartZoneDraw(ply)
	net.Start("zone_builder")
	net.WriteString(util.TableToJSON(Zones))
	if ply then 
		net.Send(ply) 
	else 
		net.Broadcast() 
	end
end

local function SaveZones()
	file.Write("savezones.txt", util.TableToJSON(Zones))
end

hook.Add("Initialize", "zones.hook", function()
	local data = file.Read("savezones.txt", "DATA")
	if data then
		Zones = util.JSONToTable(data)
	end
end) 

net.Receive("zone_builder", function(len, ply)
	if len == 0 then 
		if not ply.ZoneTransmitted then
			ply.ZoneTransmitted = true
			StartZoneDraw(ply)
		end
		return
	end

	if net.ReadBool() then
		local str = net.ReadString()
		if Zones[str] then
			Zones[str] = nil
			SaveZones()
			StartZoneDraw()
		end
	else
		local name = net.ReadString()
		local vec = net.ReadVector()
		local radius = net.ReadUInt(32)
		Zones[name] = {vec, radius}
		SaveZones()
		StartZoneDraw()
	end
end)