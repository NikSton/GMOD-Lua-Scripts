--[[
	Micro-Optimizate locals 
--]]

local create_font = surface.CreateFont
local draw_color = Color
local draw_box = draw.RoundedBox
local draw_text = draw.SimpleText
local surface_color = surface.SetDrawColor
local surface_line = surface.DrawLine
local surface_rect = surface.DrawOutlinedRect
local surface_poly = surface.DrawPoly
local PLAYER = FindMetaTable("Player")

--[[
	Creating fonts
--]]

create_font("Context_Large", {
  font = "Roboto",
  extended = false,
  size = 25,
  weight = 900,
  antialias = true,
})

create_font("Context_Small", {
  font = "Roboto",
  extended = false,
  size = 21,
  weight = 800,
  antialias = true,
})

if IsValid(cmenu) then
    cmenu:Remove()
end

--[[
	Creating Based Functions and Window-Frame
--]]

local function createFunction(func, ...) local args = {...} return function() func(unpack(args)) end end
local function command(cmd, ...) return createFunction(RunConsoleCommand, cmd, unpack({...})) end
local function category(name, content, visible) return {type = "category", isVisible = visible, content = content, name = name} end
local function option(name, content, icon, visible) return {type = "option", isVisible = visible, icon = icon, content = content, name = name} end
local function spacer(content, visible) return {type = "spacer", isVisible = visible, content = content} end
local function players(action) return {type = "playerList", action = action} end
local function sayCommand(cmd) return function(args) PLAYER.ConCommand(LocalPlayer(), "say " .. cmd .. (isstring(args) and " " .. args or "")) end end
local function drawTextBox(strTitle, strBtn, strEnter)
    local Window_Frame = vgui.Create("DFrame")
    Window_Frame:SetTitle("")
    Window_Frame:ShowCloseButton(true)
    Window_Frame:MakePopup()
    Window_Frame:SetSize(250, 100)
    Window_Frame:Center()
    Window_Frame:SetKeyboardInputEnabled(true)
    Window_Frame:SetMouseInputEnabled(true)
    Window_Frame:ShowCloseButton(false)
    Window_Frame.Paint = function(self, w, h)
        draw_box(0, 0, 0, w, h, Color(35, 35, 35))
        surface_color(255, 255, 255, 255)
        surface_line(0, 24, w, 24)
        surface_rect(0, 0, w, h)
        draw_text("Window", "Context_Large", 5, 24/2, draw_color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
  
    local Window_Close = vgui.Create("DButton", Window_Frame)
	Window_Close:SetPos(Window_Frame:GetWide() - 24, 2)
	Window_Close:SetSize(22, 22)
	Window_Close:SetText("")
	Window_Close.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local downed = self:IsDown()
		draw_box(0, 0, 0, w, h, downed and draw_color(150, 50, 50) or hovered and draw_color(200, 50, 50) or draw_color(255, 50, 50))
		draw_text("X", "MineSweeper_Small", w/2, h/2, draw_color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	Window_Close.DoClick = function()
		Window_Frame:Remove()
	end

    local Window_Text = vgui.Create( "DTextEntry", Window_Frame)
    Window_Text:SetPos(25, 35)
    Window_Text:SetSize(200, 20)
    Window_Text:SetMultiline(false)
    Window_Text:SetAllowNonAsciiCharacters(true)
    Window_Text:SetText("")
    Window_Text:SetEnterAllowed(true)

    local Window_Button = vgui.Create("DButton", Window_Frame)
    Window_Button:SetText("")
    Window_Button:SetSize(110, 20)
    Window_Button:SetPos(75, 65)
    Window_Button.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        local downed = self:IsDown()

        if hovered or downed then
		    draw_box(0, 0, 0, w, h, downed and draw_color(100, 100, 100) or draw_color(75, 75, 75))
        end

		surface_color(Color(255, 255, 255))
		surface_rect(0, 0, w, h, 2)
		draw_text(strBtn, "Context_Small", w/2, h/2, draw_color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    Window_Button.DoClick = function()
        local old_text = Window_Text:GetValue()
        strEnter(old_text)
        Window_Frame:Remove()
    end
end

--[[
	Configuration Commands
--]]

local Commands_Add = {
    /*
    option("Test Button", {
        option("Button #1", command "test_command"),
    }, "icon16/page_white_go.png", "TEAM_TEST"),
    
    category("Test Only Category", {
        option("Test", command "test_command", "icon16/page_white_go.png"),
    }, "isTest"),

    category( "Category #1", {
        option( "Test #1", {
            option("Button #1", command "test_command"),
        }, "icon16/table_edit.png" ),

        option("Test #2", {
            option("Button #1", command "test_command"),
        }, "icon16/table_edit.png" ),
    }, "isTest"),

    category("Category #2", {
        option("Test", command "test_command", "icon16/ruby.png", function(ply) return ply:GetNWBool("test") end),
    }),

    category("Category #3", {
        option("Test", createFunction(drawTextBox, "Click", "Click", sayCommand("Hello!")), "icon16/star.png"),
    }),

    option("Choose Player", {
        [0] = function()
            print("Test!")
        end,
        players(function(ply)
            print("Choose:", ply)
        end)
    }),

    option("Simple Button", function()
        print("Test!")
    end),

    option("Only Team", function()
        print("Test!")
    end, "icon16/bin_closed.png", "TEAM_TEST"),

    option("Only Extra Teams", function()
        print("Test!")
    end, nil, {"isMeta", "isOnly"}),

    option("Only Bool", function()
        print( "Test!" )
    end, nil, function(ply) return ply:GetNWBool("test") end),

    option("Exta Buttons", {
        option("Button #1", function()
            print("Test!")
        end, nil, "isMeta"),

        option("Button #2", function()
            print("Test!")
        end, nil, "isOnly"),
    }),
    */
}

--[[
	Creating Extra Functions and Hooks
--]]

local checkVisible, recursiveMenu, checkerFunction, LP

function checkerFunction(someValue, lp)
    local type = type(someValue)
    if type == "boolean" then
        return someValue

    elseif type == "table" then
        for k, v in pairs(someValue) do
            if checkerFunction(v) then
                return true
            end
        end
        return false

    elseif type == "string" then
        if PLAYER[someValue] then
            return PLAYER[someValue](LP)
        end

        if LP:Team() == _G[someValue] then
            return true
        end

        return false

    elseif type == "function" then
        return someValue(LP)
    end

    return true
end

function checkVisible(tbl)
    if tbl.isVisible then
        if not checkerFunction(tbl.isVisible) then
            return false
        end
    end

    if istable(tbl.content) then
        for k, v in pairs(tbl.content) do
            if k == 0 then continue end
            if checkVisible(v) then
                return true
            end
        end
        return false
    end
    
    return true
end

function recursiveMenu(self, tbl)
    for k, v in pairs(tbl) do
        if !istable(v) then
            continue
        end

        local valueType = v.type

        if valueType == "playerList" then
            for _, ply in pairs(player.GetAll()) do
                self:AddOption(ply:Nick(), function() if v.action then v.action(ply) end end)
            end
            continue
        end

        if not checkVisible(v) then
            continue
        end

        if valueType == "option" then
            if istable(v.content) then
                local subMenu, o = self:AddSubMenu(v.name, v.content[0])
                if v.icon then o:SetIcon(v.icon) end
                recursiveMenu(subMenu, v.content)
            else
                local o = self:AddOption(v.name, v.content)
                if v.icon then o:SetIcon(v.icon) end
            end

        elseif valueType == "category" then
            local pnl = vgui.Create("DLabel", self)
            pnl:SetContentAlignment(1)
            pnl:SetText("  " .. v.name)
            pnl:SetFont("Context_Small")
            pnl:SizeToContents()
            pnl:SetTextColor(Color(255, 255, 255))
            self:AddPanel(pnl)
            
            if v.content then
                recursiveMenu(self, v.content)
            end

        else 
            self:AddSpacer()
        end
    end
end

local newDMenu = table.Copy(vgui.GetControlTable("DMenu"))
local newDMenuOption = table.Copy(vgui.GetControlTable("DMenuOption"))

newDMenu.Init = function(self)
    self:SetIsMenu(true)
	self:SetDrawBorder(true)
	self:SetPaintBackground(true)
	self:SetMinimumWidth(100)
	self:SetDrawOnTop(true)
	self:SetMaxHeight(ScrH() * 0.9)
	self:SetDeleteSelf(true)
	self:SetPadding(0)
end

newDMenu.Open = function(self, x, y, skipanimation, ownerpanel)
	local maunal = x && y

	x = x or gui.MouseX()
	y = y or gui.MouseY()

	local OwnerHeight = 0
	local OwnerWidth = 0

	if (ownerpanel) then
		OwnerWidth, OwnerHeight = ownerpanel:GetSize()
	end

	self:InvalidateLayout(true)

	local w = self:GetWide()
	local h = self:GetTall()

	self:SetSize(w, h)

	if (y + h > ScrH()) then y = ((maunal && ScrH()) or (y + OwnerHeight)) - h end
	if (x + w > ScrW()) then x = ((maunal && ScrW()) or x) - w end
	if (y < 1 ) then y = 1 end
	if (x < 1 ) then x = 1 end

	local p = self:GetParent()

	if (IsValid(p) && p:IsModal()) then
		x, y = p:ScreenToLocal(x, y)

		if (y + h > p:GetTall()) then y = p:GetTall() - h end
		if (x + w > p:GetWide()) then x = p:GetWide() - w end
		if (y < 1) then y = 1 end
		if (x < 1) then x = 1 end

		self:SetPos(x, y)
	else
		self:SetPos(x, y)
		self:MakePopup()
	end

	self:SetVisible(true)
	self:SetKeyboardInputEnabled(false)
end

newDMenu.AddSubMenu = function(self, strText, funcFunction)
    local pnl = vgui.CreateFromTable(newDMenuOption, self, "cmenu:option")
    local SubMenu = pnl:AddSubMenu(strText, funcFunction)
    pnl:SetText(strText)
    if funcFunction then pnl.DoClick = funcFunction end
    self:AddPanel(pnl)
    return SubMenu, pnl
end

newDMenu.AddOption = function(self, strText, funcFunction)
    local pnl = vgui.CreateFromTable(newDMenuOption, self, "cmenu:option")
    pnl:SetMenu(self)
    pnl:SetText(strText)
    pnl:SetTall(pnl:GetTall() + 4)
    if funcFunction then pnl.DoClick = funcFunction end
    self:AddPanel(pnl)
    return pnl
end

newDMenu.Paint = function(self, w, h)
    draw_box(0, 0, 0, w, h, draw_color(0,0,0, 240))
    surface_color(255, 255, 255, 255)
    surface_rect(0, 0, w, h)
end

local oldInit = newDMenuOption.Init
newDMenuOption.Init = function(self)
    oldInit(self)
    self:SetFocusTopLevel(true)
    self:SetTextColor(draw_color(255, 255, 255))
end

newDMenuOption.OnMouseReleased = function(self, mousecode)
    DButton.OnMouseReleased(self, mousecode)

    if (self.m_MenuClicking && mousecode == MOUSE_LEFT) then
		self.m_MenuClicking = false
		if IsValid(cmenu) then
            cmenu:Remove()
        end
	end
end

newDMenuOption.AddSubMenu = function(self)
    local SubMenu = vgui.CreateFromTable(newDMenu, self, "cmenu:sub")
	SubMenu:SetVisible(false)
	SubMenu:SetParent(self)

	self:SetSubMenu(SubMenu)

    self.SubMenuArrow.Paint = function(panel, w, h)
        local offset = h/16
        local triangle = {
            {x = w - 5, y = offset + 2},
            {x = w, y = h/2},
            {x = w - 5, y = h-offset}
        }
        surface_color(255, 255, 255, 255)
        draw.NoTexture()
        surface_poly(triangle)
    end

	return SubMenu
end

newDMenuOption.Paint = function(self, w, h)
    local hovered = self:IsHovered()
    local downed = self:IsDown()

    if self.SubMenu and self.SubMenu:IsVisible() then
        hovered = true
    end

    draw_box(0, 2, 3, w, h - 2, draw_color(35, 35, 35, 100))

    if hovered or downed then
		draw_box(0, 2, 3, w, h - 2, downed and draw_color(100, 100, 100) or draw_color(255, 255, 255, 10))
    end
end

hook.Add("OnContextMenuOpen", "Context_Opened", function()
    LP = LocalPlayer()

    local Context_Frame = vgui.Create("DFrame", g_ContextMenu)

    cmenu = Context_Frame

    local x, y, w, h = unpack(string.Explode(";", cookie.GetString("cmenu", table.concat({0, ScrH() * 0.2, ScrW() * 0.2, ScrH() * 0.4}, ";"))))

    x, y, w, h = tonumber(x), tonumber(y), tonumber(w), tonumber(h)

    Context_Frame:SetTitle("")
    Context_Frame:SetPos(x, y)
    Context_Frame:SetSize(w, h)
    Context_Frame:SetSizable(true)
    Context_Frame:SetMinWidth(150)
    Context_Frame:SetMinHeight(150)
    Context_Frame:SetScreenLock(true)
    Context_Frame:ShowCloseButton(false)
    Context_Frame:DockPadding(0, 24, 0, 5)
    Context_Frame:SetMouseInputEnabled(true)
    Context_Frame:SetKeyboardInputEnabled(false)
    Context_Frame.IsModal = function() return true end
    Context_Frame.Paint = function(self, w, h)
        draw_box(0, 0, 0, w, 24, draw_color(35, 35, 35))
        surface_color(255, 255, 255, 255)
        surface_rect(0, 0, w, 24)
        draw_text("Context Menu", "Context_Large", w/2, 24/2, draw_color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local menu = vgui.CreateFromTable(newDMenu, Context_Frame, "cmenu")
    menu:Dock(FILL)
    menu:GetVBar():SetWide(10)
    menu.SetSize = function() end

    recursiveMenu(menu, Commands_Add)

    menu:Open(0, 0, true, Context_Frame)
end)

hook.Add("OnContextMenuClose", "Context_Closed", function()
    if !IsValid(cmenu) then return end

    local x, y = cmenu:GetPos()
    local w, h = cmenu:GetSize()

    cookie.Set("cmenu", table.concat({x, y, w, h}, ";"))

    cmenu:Remove()
end)