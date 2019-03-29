local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local helpers = require("helpers")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local alarm_sound = beautiful.alarm_sound or "/home/elena/.config/mpv/alarm.mp3"
local button_radius = beautiful.border_radius or dpi(4)

local function create_button(button_text, bg_color)
    local button_container = wibox.container.background()
    button_container.bg = bg_color
    button_container.shape = helpers.rrect(button_radius)

    local button_text = wibox.widget.textbox(button_text)
    button_text.font = "sans 15"

    -- Put the button container inside a rounded container. Why?
    -- Because I want the unrounded button corner to not be pointy!
    local button = wibox.widget {
        button_container,
        button_text,
        layout = wibox.layout.stack
    }

    helpers.add_clickable_effect(button)

    return button
end

local alarm_widget = wibox.widget {
    create_button("+1", "green"),
    create_button("+10", "green"),
    create_button("+60", "green"),
    create_button("Done", "green"),
    create_button("Cancel", "red"),
    layout = wibox.layout.fixed.horizontal
}
-- awful.spawn.easy_async_with_shell("hostname", function(out)
--     -- Remove trailing whitespaces
--     out = out:gsub('^%s*(.-)%s*$', '%1')
--     host_text.markup = helpers.colorize_text("@"..out, xcolor8)
-- end)

-- local last_notification_id
-- local function send_notification(artist, title)
--   notification = naughty.notify({
--       -- title = "Now playing:",
--       -- text = title .. " -- " .. artist,
--       title = title,
--       text = artist,
--       icon = notification_icon,
--       -- width = 360,
--       -- height = 90,
--       -- icon_size = 60,
--       timeout = 4,
--       replaces_id = last_notification_id
--   })
--   last_notification_id = notification.id
-- end

return alarm_widget
