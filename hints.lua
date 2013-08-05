local awful     = require("awful")
local client    = client
local keygrabber= keygrabber
local naughty   = require("naughty")
local pairs     = pairs
local theme     = require("theme")
local wibox     = require("wibox")

module("hints")

charorder = "jkluiopyhnmfdsatgvcewqzx1234567890"
hintbox = {} -- Table of letter wiboxes with characters as the keys

function debuginfo( message )
  nid = naughty.notify({ text = message, timeout = 10 })
end

-- Create the wiboxes, but don't show them
function init()
  hintsize = 60
  local fontcolor = theme.fg_normal
  local letterbox = {}
  for i = 1, #charorder do
    local char = charorder:sub(i,i)
    hintbox[char] = wibox({fg=theme.fg_normal, bg=theme.bg_focus, border_color=theme.border_focus, border_width=theme.border_width})
    hintbox[char].ontop = true
    hintbox[char].width = hintsize
    hintbox[char].height = hintsize
    letterbox[char] = wibox.widget.textbox()
    letterbox[char]:set_markup("<span color=\"" .. theme.fg_normal .. "\"" .. ">" .. char.upper(char) .. "</span>")
    letterbox[char]:set_font("dejavu sans mono 40")
    letterbox[char]:set_align("center")
    hintbox[char]:set_widget(letterbox[char])
  end
end

function focus()
  local hintindex = {} -- Table of visible clients with the hint letter as the keys
  local clientlist = awful.client.visible()
  for i,thisclient in pairs(clientlist) do -- Move wiboxes to center of visible windows and populate hintindex
    local char = charorder:sub(i,i)
    hintindex[char] = thisclient
    local geom = thisclient.geometry(thisclient)
    hintbox[char].visible = true
    hintbox[char].x = geom.x + geom.width/2 - hintsize/2
    hintbox[char].y = geom.y + geom.height/2 - hintsize/2
    hintbox[char].screen = thisclient.screen
  end
  keygrabber.run( function(mod,key,event)
    if event == "release" then return true end
    keygrabber.stop()
    if hintindex[key] then 
      client.focus = hintindex[key]
      hintindex[key]:raise()
    end 
    for i,j in pairs(hintindex) do
      hintbox[i].visible = false
    end
  end)
end
