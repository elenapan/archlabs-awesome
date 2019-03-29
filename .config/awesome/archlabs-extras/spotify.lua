local awful = require("awful")
local wibox = require("wibox")

local spotify_widget = wibox.widget{
    text = "Initial text. Change this to whatever or leave it empty.",
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- Update widget function
-- Run the command that gets spotify info and make the widget display its output.
local function update_widget()
    awful.spawn.easy_async_with_shell("playerctl blablabla", function(out)
        spotify_widget.text = out
    end)
end

-- Whenever the title of some client changes
client.connect_signal("property::name", function(c)
    -- Check if it is the Spotify client
    if c.class == "Spotify" then
        -- And if it is, update the widget
        update_widget()
    end
end)

return spotify_widget
