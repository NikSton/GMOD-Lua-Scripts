--[[
	Micro-Optimizate locals 
--]]

local create_font = surface.CreateFont
local run_command = concommand.Add
local draw_color = Color
local get_material = Material
local draw_box = draw.RoundedBox
local draw_text = draw.SimpleText
local surface_color = surface.SetDrawColor
local surface_line = surface.DrawLine
local surface_rect = surface.DrawOutlinedRect
local surface_material = surface.SetMaterial
local surface_texturect = surface.DrawTexturedRect
local fuck_string = tostring
local fuck_random = math.random
local bomb_icon = get_material("minesweeper/bombaaaaaa.png")
local mark_icon = get_material("minesweeper/flaaaaaaag.png")

--[[
	Creating fonts
--]]

create_font("MineSweeper_Large", {
  font = "Roboto",
  extended = false,
  size = 21,
  weight = 900,
  antialias = true,
})

create_font("MineSweeper_Medium", {
  font = "Roboto",
  extended = false,
  size = 19,
  weight = 800,
  antialias = true,
})

create_font("MineSweeper_Small", {
  font = "Roboto",
  extended = false,
  size = 17,
  weight = 700,
  antialias = true,
})

create_font("MineSweeper_Extra", {
  font = "Roboto",
  extended = false,
  size = 24,
  weight = 999,
  antialias = true,
})

--[[
	Creating Panels and functions
--]]

function MineSweeper.CreateMenu()
	if IsValid(MineSweeper_Menu) then MineSweeper_Menu:Remove() return end
	local MineSweeper_Menu = vgui.Create("DFrame")
	MineSweeper_Menu:SetSize(200, 200)
	MineSweeper_Menu:MakePopup()
	MineSweeper_Menu:Center()
	MineSweeper_Menu:SetTitle("")
    MineSweeper_Menu:ShowCloseButton(false)
	MineSweeper_Menu.Paint = function(s, w, h)
		draw_box(0, 0, 0, w, h, draw_color(35, 35, 35))
		surface_color(draw_color(255, 255, 255))
		surface_line(0, 24, w, 24)
		surface_rect(0, 0, w, h, 2)
        draw_text("MineSweeper(BETA)", "MineSweeper_Large", 5, 24/2, draw_color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local MineSweeper_Close = vgui.Create("DButton", MineSweeper_Menu)
	MineSweeper_Close:SetPos(MineSweeper_Menu:GetWide() - 24, 2)
	MineSweeper_Close:SetSize(22, 22)
	MineSweeper_Close:SetText("")
	MineSweeper_Close.Paint = function(self, w, h)
		draw_box(0, 0, 0, w, h, self:IsDown() and draw_color(150, 50, 50) or self:IsHovered() and draw_color(200, 50, 50) or draw_color(255, 50, 50))
		draw_text("X", "MineSweeper_Extra", w/2, h/2, draw_color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	MineSweeper_Close.DoClick = function()
		MineSweeper_Menu:Remove()
	end

	local MineSweeper_List = vgui.Create("DPanel", MineSweeper_Menu)
	MineSweeper_List:SetSize(105, 25+30 * #MineSweeper.Config.Difficulties)
	MineSweeper_List:SetPos(100-50, 35)

	MineSweeper_List.Paint = function(self, w, h)
		draw_box(2, 0, 0, w, h, draw_color(99,99,99))
		surface_color(draw_color(255, 255, 255))
		surface_rect(0, 0, w, h)
		draw_text("DIFFICULTY", "MineSweeper_Medium", w/2, h-20, draw_color(0, 0, 0), TEXT_ALIGN_CENTER)
	end

	for i, v in ipairs(MineSweeper.Config.Difficulties) do
		local MineSweeper_Buttons = vgui.Create("DButton", MineSweeper_List)
		MineSweeper_Buttons:SetSize(90, 25)
		MineSweeper_Buttons:SetPos(5, 5+30 * (i-1))
		MineSweeper_Buttons:SetText("")
		MineSweeper_Buttons.Paint = function(self, w, h)
		if self:IsHovered() or self:IsDown() then
		draw_text(v.name, "MineSweeper_Medium", w/2, h/2, self:IsDown() and v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
			self:SetCursor("hand")
		else
		    draw_text(v.name, "MineSweeper_Medium", w/2, h/2, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)		
		end
	end
		MineSweeper_Buttons.DoClick = function()
			MineSweeper_Menu:GenerateGame(v.bombs, v.x, v.y)
		end
	end

	function MineSweeper_Menu:GenerateGame(bombs, x, y)
		local MineSweeper_Panel = vgui.Create("DPanel", self)
		MineSweeper_Panel:SetSize(x * 36+6, y * 36+6)
		MineSweeper_List:Remove()
		self:SetSize(x * 36+16, y * 36+41)
		MineSweeper_Panel:SetPos(5, 30)
		MineSweeper_Close:SetPos(MineSweeper_Panel:GetWide() - 14, 2)
		self:Center()

		local bomb_list = {}
		local bombs_to_give = bombs

		for iy = 1, y do
			for ix = 1, x do
				local data = {
					pos_x = 36 * (ix-1),
					pos_y = 36 * (iy-1),
					is_bomb = false,
					near_bomb_amount = 0,
					panel = nil,
					hidden = true,
					marked = false,
				}
				bomb_list["button_"..iy.."_"..ix] = data
			end
		end

		while bombs_to_give != 0 do
			local picked = "button_".. fuck_random(1, y) .."_".. fuck_random(1, x)
			if bomb_list[picked].is_bomb then continue end
			bomb_list[picked].is_bomb = true
			bombs_to_give = bombs_to_give - 1
		end

		for iy = 1, y do
			for ix = 1, x do
				if bomb_list["button_"..iy.."_"..ix].is_bomb then continue end

				if bomb_list["button_"..(iy+1).."_"..ix] and bomb_list["button_"..(iy+1).."_"..ix].is_bomb then
					bomb_list["button_"..iy.."_"..ix].near_bomb_amount = bomb_list["button_"..iy.."_"..ix].near_bomb_amount + 1
				end

				if bomb_list["button_"..(iy+1).."_"..(ix+1)] and bomb_list["button_"..(iy+1).."_"..(ix+1)].is_bomb then
					bomb_list["button_"..iy.."_"..ix].near_bomb_amount = bomb_list["button_"..iy.."_"..ix].near_bomb_amount + 1
				end

				if bomb_list["button_"..iy.."_"..(ix+1)] and bomb_list["button_"..iy.."_"..(ix+1)].is_bomb then
					bomb_list["button_"..iy.."_"..ix].near_bomb_amount = bomb_list["button_"..iy.."_"..ix].near_bomb_amount + 1
				end

				if bomb_list["button_"..(iy-1).."_"..ix] and bomb_list["button_"..(iy-1).."_"..ix].is_bomb then
					bomb_list["button_"..iy.."_"..ix].near_bomb_amount = bomb_list["button_"..iy.."_"..ix].near_bomb_amount + 1
				end

				if bomb_list["button_"..(iy-1).."_"..(ix-1)] and bomb_list["button_"..(iy-1).."_"..(ix-1)].is_bomb then
					bomb_list["button_"..iy.."_"..ix].near_bomb_amount = bomb_list["button_"..iy.."_"..ix].near_bomb_amount + 1
				end

				if bomb_list["button_"..iy.."_"..(ix-1)] and bomb_list["button_"..iy.."_"..(ix-1)].is_bomb then
					bomb_list["button_"..iy.."_"..ix].near_bomb_amount = bomb_list["button_"..iy.."_"..ix].near_bomb_amount + 1
				end

				if bomb_list["button_"..(iy-1).."_"..(ix+1)] and bomb_list["button_"..(iy-1).."_"..(ix+1)].is_bomb then
					bomb_list["button_"..iy.."_"..ix].near_bomb_amount = bomb_list["button_"..iy.."_"..ix].near_bomb_amount + 1
				end

				if bomb_list["button_"..(iy+1).."_"..(ix-1)] and bomb_list["button_"..(iy+1).."_"..(ix-1)].is_bomb then
					bomb_list["button_"..iy.."_"..ix].near_bomb_amount = bomb_list["button_"..iy.."_"..ix].near_bomb_amount + 1
				end
			end
		end

		for iy = 1, y do
			for ix = 1, x do
				local MineSweeper_Click = vgui.Create("DButton", MineSweeper_Panel)
				bomb_list["button_"..iy.."_"..ix].panel = MineSweeper_Click
				MineSweeper_Click:SetSize(30, 30)
				MineSweeper_Click:SetText("")

				function MineSweeper_Click:TakeNearClearChunks()
					local check_x, check_y = 1, 0

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden and !bomb_list["button_"..iy+check_x.."_"..ix+check_y].is_bomb then
						bomb_list["button_"..iy+check_x.."_"..ix+check_y].panel.DoClick(bomb_list["button_"..iy+check_x.."_"..ix+check_y].panel, bomb_list["button_"..iy+check_x.."_"..ix+check_y].near_bomb_amount > 0)
					end

					check_x, check_y = -1, 0

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden and !bomb_list["button_"..iy+check_x.."_"..ix+check_y].is_bomb then
						bomb_list["button_"..iy+check_x.."_"..ix+check_y].panel.DoClick(bomb_list["button_"..iy+check_x.."_"..ix+check_y].panel, bomb_list["button_"..iy+check_x.."_"..ix+check_y].near_bomb_amount > 0)
					end

					check_x, check_y = 0, 1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden and !bomb_list["button_"..iy+check_x.."_"..ix+check_y].is_bomb then
						bomb_list["button_"..iy+check_x.."_"..ix+check_y].panel.DoClick(bomb_list["button_"..iy+check_x.."_"..ix+check_y].panel, bomb_list["button_"..iy+check_x.."_"..ix+check_y].near_bomb_amount > 0)
					end

					check_x, check_y = 0, -1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden and !bomb_list["button_"..iy+check_x.."_"..ix+check_y].is_bomb then
						bomb_list["button_"..iy+check_x.."_"..ix+check_y].panel.DoClick(bomb_list["button_"..iy+check_x.."_"..ix+check_y].panel, bomb_list["button_"..iy+check_x.."_"..ix+check_y].near_bomb_amount > 0)
					end
				end
	
				function MineSweeper_Click:GetNearbies()
					local check_x, check_y = 1, 0
                    
					local check_list = {}

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = 1, 1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = 0, 1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = -1, 0

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = -1, -1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = 0, -1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = 1, 1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = -1, -1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = -1, 1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end

					check_x, check_y = 1, -1

					if bomb_list["button_"..iy+check_x.."_"..ix+check_y] and bomb_list["button_"..iy+check_x.."_"..ix+check_y].hidden then
						check_list[bomb_list] = bomb_list["button_"..iy+check_x.."_"..ix+check_y]
					end
					return check_list
				end

				MineSweeper_Click:SetText("")

				MineSweeper_Click.DoClick = function(self, nocheck)
					if !bomb_list["button_"..iy.."_"..ix].hidden and bomb_list["button_"..iy.."_"..ix].near_bomb_amount > 0 then
						local check_x, check_y = 1, 0
						local check_list = self:GetNearbies()
						local marked_sum = 0

						for _, v in pairs(check_list) do
							if v.marked then
								marked_sum = marked_sum + 1
							end
						end

					if marked_sum < bomb_list["button_"..iy.."_"..ix].near_bomb_amount then
							return
						else
							for _, v in pairs(check_list) do
								if !v.marked then v.panel.DoClick(v.panel) end
							end
						end
						return
					end

					local check_text = MineSweeper_Click:GetText()
					if MineSweeper.Config.TextColors[check_text] then
						MineSweeper_Click:SetTextColor(MineSweeper.Config.TextColors[check_text])
					end

					bomb_list["button_"..iy.."_"..ix].hidden = false

					if bomb_list["button_"..iy.."_"..ix].is_bomb then
						for _, tab in pairs(bomb_list) do
							tab.hidden = false
						end
					end

					if !nocheck and !bomb_list["button_"..iy.."_"..ix].is_bomb and bomb_list["button_"..iy.."_"..ix].near_bomb_amount <= 0 then 
						self:TakeNearClearChunks() 
					end
				end

				MineSweeper_Click.DoRightClick = function(self)
					if !bomb_list["button_"..iy.."_"..ix].hidden then return end
					bomb_list["button_"..iy.."_"..ix].marked = !bomb_list["button_"..iy.."_"..ix].marked
				end

				MineSweeper_Click.Paint = function(self, w, h)
					local hidden_color = draw_color(25, 25, 25)
					local not_hidden_color = draw_color(215, 215, 215)
					local tab = bomb_list["button_"..iy.."_"..ix]

					if !tab.hidden then hidden_color = not_hidden_color end

					draw_box(0, 0, 0, w, h, hidden_color)

					if !tab.hidden then
						if tab.is_bomb then
							surface_color(255, 255, 255, 255)
							surface_material(bomb_icon)
							surface_texturect(7, 7, 15, 15)
						elseif tab.near_bomb_amount > 0 then
							draw_text(fuck_string(tab.near_bomb_amount), "MineSweeper_Small", w/2, h/2-5, MineSweeper.Config.TextColors[tab.near_bomb_amount], TEXT_ALIGN_CENTER)
						end
					else
						if tab.marked then
							surface_color(255, 255, 255, 255)
							surface_material(mark_icon)
							surface_texturect(7, 7, 15, 15)
						end
					end
				end
			MineSweeper_Click:SetPos(bomb_list["button_"..iy.."_"..ix].pos_x + 6, bomb_list["button_"..iy.."_"..ix].pos_y + 6)
		end
	end
		return MineSweeper_Panel, MineSweeper_Panel:GetSize()
	end
end

--[[
	Three ways to open a MineSweeper
--]]

net.Receive("MineSweeper_RunGame", function()
	MineSweeper.CreateMenu()
end)

run_command(MineSweeper.Config.Console_Command, function()
	MineSweeper.CreateMenu()
end)

list.Set("DesktopWindows", "MineSweeper by NikSton", {
	title = "MineSweeper",
	icon  = "minesweeper/mineeeeeicon.png",
	init  = function()
		MineSweeper.CreateMenu()
	end
})