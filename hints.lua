-- hints.lua --- window picker and hints for awesome
-- 
-- Source: https://github.com/zackpete/hints
-- License: GPLv2
--
-- Usage:
--   hints = require('hints')
--
--   -- Set the prefered order of accelerators if you don't like the default.
--   hints.charoder = 'jkluiopyhnmfdsatgvcewqzx1234567890'
--
--   -- Initialize the module (must come after beautiful.init()).
--   hints.init()
--
--   -- Add a keybinding to globalkeys.
--   awful.key({ modkey }, "j", function () hints.focus() end),

local awful     = require("awful")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local client    = client
local keygrabber= keygrabber

local hints = {
   charorder = "jkluiopyhnmfdsatgvcewqzx1234567890",
   hintbox = {} -- Table of letter wiboxes with characters as the keys
}

local debuginfo = function (message)
  nid = naughty.notify({ text = message, timeout = 10 })
end

-- Create the wiboxes, but don't show them
function hints.init()
  hintsize = 60
  local fontcolor = beautiful.fg_normal
  local letterbox = {}

  for i = 1, #hints.charorder do
    local char = hints.charorder:sub(i,i)
    hints.hintbox[char] = wibox({fg=beautiful.fg_normal, bg=beautiful.bg_focus, border_color=beautiful.border_focus, border_width=beautiful.border_width})
    hints.hintbox[char].ontop = true
    hints.hintbox[char].width = hintsize
    hints.hintbox[char].height = hintsize

    letterbox[char] = wibox.widget.textbox()
    letterbox[char]:set_markup("<span color=\"" .. beautiful.fg_normal .. "\"" .. ">" .. char.upper(char) .. "</span>")
    letterbox[char]:set_font("dejavu sans mono 40")
    letterbox[char]:set_align("center")

    hints.hintbox[char]:set_widget(letterbox[char])
  end
end

function hints.focus()
  local hintindex = {} -- Table of visible clients with the hint letter as the keys
  local clientlist = awful.client.visible()

  -- Move wiboxes to center of visible windows and populate hintindex
  for i, thisclient in pairs(clientlist) do
    local char = hints.charorder:sub(i,i)
    hintindex[char] = thisclient
    local geom = thisclient.geometry(thisclient)
    hints.hintbox[char].visible = true
    hints.hintbox[char].x = geom.x + geom.width/2 - hintsize/2
    hints.hintbox[char].y = geom.y + geom.height/2 - hintsize/2
    hints.hintbox[char].screen = thisclient.screen
  end

  keygrabber.run( function(mod,key,event)
    if event == "release" then return true end
    keygrabber.stop()

    if hintindex[key] then 
      client.focus = hintindex[key]
      hintindex[key]:raise()
    end 

    for i,j in pairs(hintindex) do
      hints.hintbox[i].visible = false
    end
  end)
end

return hints
