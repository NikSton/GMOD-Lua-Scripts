TOOL.Name = "Zones Tool"
TOOL.Category = "Simple Zones Builder"

if SERVER then return end

TOOL.ClientConVar["radius"] = 100
language.Add("tool.zonebuilder.name", "Zones")
language.Add("tool.zonebuilder.desc", "Author: NikSton")
language.Add("tool.zonebuilder.warning", "WARNING: After you have created the zone, reconnect to the server!")
language.Add("tool.zonebuilder.radius", "Radius")
language.Add("tool.zonebuilder.list", "List Zones")
language.Add("tool.zonebuilder.remove", "Delete zone")

function TOOL:LeftClick(trace)
    local spamClick = 0
	if spamClick > CurTime() then return end
	spamClick = CurTime() + 0.5
	local radius = self:GetClientInfo("radius")
	Derma_StringRequest("Zone Creator", "Enter zone name", "Name", function(name)
		net.Start("zone_builder")
		net.WriteBool(false)
		net.WriteString(name)
		net.WriteVector(trace.HitPos)
		net.WriteUInt(math.floor(radius), 32)
		net.SendToServer()
	end, nil, "Create", "Cancel")
end

function TOOL:Reload(trace)
    local spamClick = 0
	if spamClick > CurTime() then return end
	spamClick = CurTime() + 0.5
	local radius = self:GetClientInfo("radius")
    Derma_StringRequest("Zone Creator", "Enter zone name", "Name", function(name)
		net.Start("zone_builder")
		net.WriteBool(false)
		net.WriteString(name)
		net.WriteVector(trace.HitPos)
		net.WriteUInt(math.floor(radius), 32)
		net.SendToServer()
	end, nil, "Create", "Cancel")
end

function TOOL:RightClick(trace)
    local spamClick = 0
	if spamClick > CurTime() then return end
	spamClick = CurTime() + 0.5
	local radius = self:GetClientInfo("radius")
    Derma_StringRequest("Zone Creator", "Enter zone name", "Name", function(name)
		net.Start("zone_builder")
		net.WriteBool(false)
		net.WriteString(name)
		net.WriteVector(trace.HitPos)
		net.WriteUInt(math.floor(radius), 32)
		net.SendToServer()
	end, nil, "Create", "Cancel")
end

local function update_list() end -- TODO: Fix function for tool!

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Text = "#tool.zonebuilder.name",
		Description = "#tool.zonebuilder.desc"
	})
	
	CPanel:AddControl("Slider", {
		Label = "#tool.zonebuilder.radius",
		Command = "zonebuilder_radius",
		Type = "Int",
		Min = 100,
		Max = 5000
	})
   
	local listbox = CPanel:AddControl("ListBox", {
		Label = "#tool.zonebuilder.list",
		Height = 100
	})
    
	CPanel:ControlHelp("#tool.zonebuilder.warning")

	local btn = vgui.Create("DButton", CPanel)
	btn:Dock(TOP)
	btn:SetTall(30)
	btn:DockMargin(50, 10, 50, 0)
	btn:SetText("#tool.zonebuilder.remove")

	function update_list()
		if not IsValid(listbox) then return end
		listbox:Clear()
		for zone_name, v in pairs(Zones) do
			local line = listbox:AddLine(zone_name)
			line.data = {}
			line.name = zone_name
		end
	end

	update_list()

	btn.DoClick = function()
		if listbox:GetSelected() and listbox:GetSelected()[1] then
			net.Start("zone_builder")
			net.WriteBool(true)
			net.WriteString(listbox:GetSelected()[1].name)
			net.SendToServer()
		end
	end
end

net.Receive("zone_builder", function()
	local tbl = util.JSONToTable(net.ReadString())
	Zones = tbl
	update_list()
end)

local enabled = false
function TOOL:Think()
	enabled = CurTime() + 1
end

local function DrawFrameBox(pos, radius, name)
	local pos = pos + Vector(0, 0, 0)
	local size = Vector(radius, radius, radius/2)/1.5
	local wire_framebox = render.DrawWireframeBox
	local draw_text = draw.SimpleText
	local draw_color = Color
	local Start2D = cam.Start2D
	local End2D = cam.End2D

	wire_framebox(pos, Angle(0,0,0), -size, size, draw_color(255,255,255), false)

	Start2D()
	    local pos = pos:ToScreen()
		draw_text(name, "Default", pos.x, pos.y, draw_color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	End2D()
end

hook.Add("PostDrawOpaqueRenderables", "zones.hook", function()
	if not enabled or enabled < CurTime() then return end
	
	for zone_name, data in pairs(Zones) do
		DrawFrameBox(data[1], data[2], zone_name)
	end
	
	local tool = LocalPlayer():GetTool()
	local radius = tool:GetClientInfo("radius") or 0
	DrawFrameBox(LocalPlayer():GetEyeTrace().HitPos, radius, "New zone")
end)

hook.Add("InitPostEntity", "zones.hook", function()
	net.Start("zone_builder")
	net.SendToServer()
end)