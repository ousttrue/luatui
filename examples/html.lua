local Screen = require "luatui.Screen"

local s = Screen.make_tty_screen()

s.root.callbacks = {
  keymap = function(input)
    if input.data == "q" then
      return "exit"
    end
  end,
  ---@param rt RenderTarget
  ---@param viewport Viewport
  render = function(rt, viewport)
    rt:write(0, 0, "q: quit")
    rt:write(1, 0, "hit enter...")
  end,
}

s:render()

s:run()
