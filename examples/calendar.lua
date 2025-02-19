local Screen = require "luatui.Screen"

local s = Screen.make_tty_screen()

local DAYS = {
  "Sun",
  "Mon",
  "Tue",
  "Wed",
  "Thu",
  "Fri",
  "Sat",
}

s.root.callbacks = {
  keymap = function(input)
    if input.data == "q" then
      return "exit"
    end
  end,
  render = function(rt, viewport)
    -- 7x5 block
    local x = 0
    local w = viewport.width / 7
    for i = 1, 7 do
      rt:box(x, 0, w, math.floor(w / 2), DAYS[i])
      x = x + w
    end
  end,
}

s:run()
