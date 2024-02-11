local ActiveZone = ""
local Enabled = false
local hud_fix = ScrW() <= 1080 and 0.9 or ScrW() > 1280 and 1.5 or 1
local set_font = surface.SetFont
local text_size = surface.GetTextSize
local draw_text = draw.SimpleText
local draw_color = Color

timer.Create("Zone_Update", 1, 0, function()
    if IsValid(LocalPlayer()) then
        local pos = LocalPlayer():GetPos()
        for key, value in pairs(Zones) do
            if value[1]:Distance(pos) < value[2] then
                ActiveZone = key
                Enabled = true
                return
            end
        end
    end
    Enabled = false
end)

local function ZoneHud()
if Enabled then
    local text = "Zone: " .. ActiveZone
    set_font("DermaLarge")
    local size_x = text_size(text)
	draw_text(text,"DermaLarge", 1 * hud_fix, 5, draw_color(255,255,255))
	end
end
hook.Add("HUDPaint", "zones.hook", ZoneHud)