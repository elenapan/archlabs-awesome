------------ MPV - On Screen Control ------------
-- Dependencies:
--      socat: send and receive messages through sockets
--      jq:    parse json output
--
-- You also need to have the following lines in your ~/.config/mpv/mpv.conf:
--      input-ipc-server=/tmp/mpv.socket
--      no-osc
--
-- Alternatively, you can run mpv with the above options as follows:
--      mpv --input-ipc-server=/tmp/mpv.socket --no-osc <file>
-- 
-- The first option specifies a socket through which we send / receive messages to / from mpv
-- The second option disables the default onscreen control pseudo gui (optional).
--
-- NOTE: The OSD widgets work only with 1 mpv client open
-- This is because as ...
-- Using JSON IPC for mpv to send and receive messages from the shell
-- Find all mpv properties with "mpv --list-properties"
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- TODO
local naughty = require("naughty")

local helpers = require("helpers")
local pad = helpers.pad

-- Configuration
local mpv_socket = "/tmp/mpv.socket"

-- todo if return command == "Null or null idk" or includes connection refused
-- send notification on event "end-file"? or some playlist end?

-- Create the OSD bar
mpv_osd = wibox({visible = false, ontop = true, type = "dock"})

mpv_osd.bg = beautiful.fg_minimize
-- mpv_osd.fg = beautiful.bg_dark
-- mpv_osd.bg = beautiful.fg_focus
-- mpv_osd.bg = beautiful.mpv_osd_bg or beautiful.wibar_bg or "#111111"
mpv_osd.fg = beautiful.mpv_osd_fg or beautiful.wibar_fg or "#FFFFFF"
mpv_osd.opacity = beautiful.mpv_osd_opacity or 1
mpv_osd.height = beautiful.mpv_osd_height or 60
local radius = beautiful.border_radius or 0
mpv_osd.shape = helpers.prrect(radius, false, false, true, true)

mpv_osd:buttons(gears.table.join(
                  -- Middle click - Hide mpv_osd
                  awful.button({ }, 2, function ()
                      mpv_osd.visible = false
                  end),
                  -- Right click - Hide mpv_osd
                  awful.button({ }, 3, function ()
                      mpv_osd.visible = false
                  end)
))

-- Gotta set the right size and position before making it visible
mpv_osd_show = function(cgeo)
    mpv_osd.x = cgeo.x
    mpv_osd.y = cgeo.y + cgeo.height - mpv_osd.height
    mpv_osd.width = cgeo.width
    mpv_osd.visible = true
end

mpv_osd_toggle = function(cgeo)
    if mpv_osd.visible then
        mpv_osd.visible = false
    else
        mpv_osd_show(cgeo)
    end
end

-- Hide OSD when mouse leaves
mpv_osd:connect_signal("mouse::leave", function ()
    mpv_osd.visible = false
    end)

-- Control commands (prev/play/next)
local mpv_toggle_command = "echo '{ \"command\": [\"cycle\", \"pause\"] }' | socat - "..mpv_socket.." | jq \".data\""
local mpv_next_command = "echo '{ \"command\": [\"playlist_next\"] }' | socat - "..mpv_socket.." | jq \".data\""
local mpv_prev_command = "echo '{ \"command\": [\"playlist_prev\"] }' | socat - "..mpv_socket.." | jq \".data\""

-- Helper functions that construct JSON IPC commands
local mpv_get_property_command = function(name)
    return "echo '{ \"command\": [\"get_property\", \""..name.."\"] }' | socat - "..mpv_socket.." | jq \".data\""
end
local mpv_set_property_command = function(name, value)
    return "echo '{ \"command\": [\"set_property\", \""..name.."\", "..value.."] }' | socat - "..mpv_socket
    -- return "echo '{ \"command\": [\"set_property\", \""..name.."\", "..value.."] }' | socat - "..mpv_socket.." | jq \".error\""
end

-- Items
local mpv_file = wibox.widget.textbox("My neighbour Totoro (2009)")
mpv_file.font = "sans 18 medium"
mpv_file:buttons(gears.table.join(
                  -- Middle click - Hide mpv_osd
                  awful.button({ }, 1, function ()
                      mpv_get_property("playback-time")
                  end),
                  awful.button({ }, 3, function ()
                      mpv_set_property("loop", "true")
                  end)
))

local mpv_button_size = 40

local mpv_toggle_icon = wibox.widget.imagebox(beautiful.playerctl_toggle_icon)
mpv_toggle_icon.resize = true
mpv_toggle_icon.forced_width = mpv_button_size
mpv_toggle_icon.forced_height = mpv_button_size
mpv_toggle_icon:buttons(gears.table.join(
                        awful.button({ }, 1, function ()
                            awful.spawn.with_shell(mpv_toggle_command)
                            -- local command = mpv_get_property_command("pause")
                            -- awful.spawn.easy_async_with_shell(command, function(out)
                            --     local toggle_command
                            --     if out:match('true') then
                            --         toggle_command = mpv_set_property_command("pause", "false")
                            --     else
                            --         toggle_command = mpv_set_property_command("pause", "true")
                            --     end
                            -- end)
                        end)
))

local mpv_prev_icon = wibox.widget.imagebox(beautiful.playerctl_prev_icon)
mpv_prev_icon.resize = true
mpv_prev_icon.forced_width = mpv_button_size
mpv_prev_icon.forced_height = mpv_button_size
mpv_prev_icon:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                            awful.spawn.with_shell(mpv_prev_command)
                         end)
))

local mpv_next_icon = wibox.widget.imagebox(beautiful.playerctl_next_icon)
mpv_next_icon.resize = true
mpv_next_icon.forced_width = mpv_button_size
mpv_next_icon.forced_height = mpv_button_size
mpv_next_icon:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                            awful.spawn.with_shell(mpv_next_command)
                         end)
))

local mpv_buttons = wibox.widget {
  nil,
  {
    mpv_prev_icon,
    pad(1),
    mpv_toggle_icon,
    pad(1),
    mpv_next_icon,
    layout  = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.vertical,
}

local mpv_progress = wibox.widget.textbox("6:14 / 13:25")
mpv_progress.font = "sans 18 medium"

-- Item placement
mpv_osd:setup {
  { ----------- LEFT GROUP -----------
    pad(2),
    mpv_file,
    layout = wibox.layout.fixed.horizontal
  },
  { ----------- MIDDLE GROUP -----------
    mpv_buttons,
    layout = wibox.layout.fixed.horizontal
  },
  { ----------- RIGHT GROUP -----------
    mpv_progress,
    pad(2),
    layout = wibox.layout.fixed.horizontal
  },
  layout = wibox.layout.align.horizontal,
  expand = "none"
}

-- local mpv_event_listener_script = [[
--   bash -c '
--     socat - ]]..mpv_socket..[[
-- ']]
local mpv_event_listener_script = [['socat - ]]..mpv_socket..[[']]

-- Every time a client with class "mpv" spawns
client.connect_signal("manage", function (c)
    if c.class == "mpv" then
        naughty.notify { text = "script: "..mpv_event_listener_script }
        print(mpv_event_listener_script)
        -- Listen for events
        awful.spawn.with_line_callback(mpv_event_listener_script, { stdout = function(line)
            naughty.notify { text = "LINE: "..line }
            end
        })

        -- Get file name
        local get_filename = mpv_get_property_command("media-title")
        awful.spawn.easy_async_with_shell(get_filename, function(out)
            mpv_file.text = out:match('".*"')
        end)

        -- Show the OSD bar when the mouse enters and only if the client is focused
        c:connect_signal ("mouse::enter",
          function ()
            if c == client.focus and mpv_osd.visible == false then
              mpv_osd_show(c:geometry())
            end
          end
        )

        -- Hide the OSD bar when the mouse leaves
        c:connect_signal ("mouse::leave",
          function ()
            m = mouse.coords()
            -- NOTE: Only hide the bar if the mouse is actually out of the bar not just out of the client.
            -- This is needed because the bar is on top of the client.
            -- Thus, this function is also called when the mouse goes from the client to the bar.
            --In that case, we do not want it to hide. (Instead, we add a "mouse::leave" signal on the bar itself, see somewhere above)
            if   m.x < mpv_osd.x
              or m.x > (mpv_osd.x + mpv_osd.width)
              or m.y > (mpv_osd.y + mpv_osd.width)
              or m.y < mpv_osd.y then
              mpv_osd.visible = false
            end
          end
        )
        -- Show the bar when the window gets focused
        c:connect_signal ("focus",
          function ()
            mpv_osd_show(c:geometry())
          end
        )
        -- Hide bar when the window is resized or moved
        c:connect_signal ("property::geometry",
          function ()
            mpv_osd.visible = false
          end
        )
        -- Hide bar when the window is unfocused
        c:connect_signal ("unfocus",
          function ()
            mpv_osd.visible = false
          end
        )
        -- Hide bar when the window is killed
        c:connect_signal ("unmanage",
          function ()
            mpv_osd.visible = false
          end
        )
    end
end)

return mpv_osd
