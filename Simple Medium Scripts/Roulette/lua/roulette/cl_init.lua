--[[
	Micro-Optimizate locals
--]]

local create_font = surface.CreateFont
local add_text = chat.AddText
local draw_color = Color
local draw_box = draw.RoundedBox
local surface_color = surface.SetDrawColor
local surface_rect = surface.DrawOutlinedRect
local draw_text = draw.SimpleText
local table_add = table.Add
local un_fuck = unpack

--[[
	Creating font
--]]

create_font("Cards_Text", {
  font = "Roboto",
  extended = false,
  size = 24,
  weight = 900,
  antialias = true,
})

--[[
	Creating Notify, cards and Animations
--]]

local function Roulette_Notify(meWin, target)
	add_text(
        draw_color(255, 255, 255),    "[",
        draw_color(255, 255, 0),     "Roulette",
        draw_color(255, 255, 255),    "] ",
    meWin and draw_color(50, 255, 50) or draw_color(255, 50, 50), (target or "he or she") .. (meWin and " lost!" or " won!"))
end

local function Winner_Card(x, y, w, h)
	draw_box(0, x, y, w, h, draw_color(0, 0, 0))
	surface_color(255, 255, 255)
	surface_rect(x, y, w, h, 2)
	draw_text("Luck", "Cards_Text", x + w/2, y + h/2, draw_color(50, 255, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function Loser_Card(x, y, w, h)
	draw_box(0, x, y, w, h, draw_color(0, 0, 0))
	surface_color(255, 255, 255)
	surface_rect(x, y, w, h, 2)
	draw_text("Bad luck", "Cards_Text", x + w/2, y + h/2, draw_color(255, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function Roulette_Animation(win, count, target)
	local panel = vgui.Create("EditablePanel")
	panel:SetSize(400, 50)
	panel:SetPos(ScrW()/2 - panel:GetWide()/2, ScrH()/2 - panel:GetTall( )/2)

	local cards = {}
	for i = 1, count + 4 do
		cards[i] = math.random() < 0.5
	end

	cards[count] = win

	local offset = 0
	local speed = 0.005
	local card_wide = 120
	local last_offset = (count - 2) * card_wide + math.random(5, card_wide - 5)

	panel.Paint = function(self, w, h)
		draw_box(0, 0, 0, w, h, draw_color(50, 50, 50, 250))

		if offset <= last_offset - 2 then
			offset = offset + (last_offset - offset) * speed
		else
			Roulette_Notify(win, target)
			panel:Remove()
			return
		end	

		local start = math.ceil(offset / card_wide)
		for i = -1, 4 do
			if cards[start + i] then
				Winner_Card((start + i) * card_wide - offset, 0, card_wide, 50)
			elseif cards[start + i] == false then
				Loser_Card((start + i) * card_wide - offset, 0, card_wide, 50)
			elseif cards[start + i] == nil then
				draw_box(0, (start + i) * card_wide - offset, 0, card_wide, 50, draw_color(0, 0, 0))
				surface_color(255, 0, 0)
				surface_rect((start + i ) * card_wide - offset, 0, card_wide, 50, 2)
			end
		end
		draw_box(0, w/2 - 1, 0, 2, h, draw_color(255, 255, 255))
	end
end

net.Receive("Roulette_Start", function()
	Roulette_Animation(net.ReadBool(), net.ReadUInt(9), net.ReadString())
end)

net.Receive("Roulette_Chat", function()
    local msgtext = net.ReadUInt(2)
    local message = Roulette.Config.Messages[msgtext]
    if not message then return end
    local prefix = Roulette.Config.Messages["Prefix"]
    local msg = {}
    table_add(msg, prefix)
    table_add(msg, message)
    add_text(un_fuck(msg))
end)