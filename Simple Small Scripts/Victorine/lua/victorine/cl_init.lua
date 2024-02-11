net.Receive("Victorine", function(len, ply)
    local type = net.ReadUInt(3)
    local value = net.ReadType()
    local AddText = chat.AddText
    local draw_color = Color
    local message = {
        draw_color(255, 255, 255), "[",
        draw_color(50, 255, 50), "Victorine",
        draw_color(255, 255, 255), "] ",
    }

    if type == 1 then
        table.Add(message, {
            draw_color(255, 100, 100), "Answer the question",
            draw_color(255, 255, 255), ": ",
            value
        })
        
    elseif type == 2 then
        table.Add(message, {
            draw_color(255, 100, 100), "Solve a math example",
            draw_color(255, 255, 255), ": ",
            value
        })
        
    elseif type == 3 and istable(value) and IsValid(value[1]) and value[1]:IsPlayer() then
        table.Add(message, {
            draw_color(255, 100, 100), value[1]:Nick(),
            draw_color(255, 255, 255), " won the victorine!"
        })

    elseif type == 4 then 
        table.Add(message, {
            draw_color(255, 0, 0), "Nobody won!"
        })
    end

    AddText(unpack(message))
end)