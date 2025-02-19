---@type uv
local uv = require "luv"
local Screen = require "luatui.Screen"
local Splittr = require "luatui.Splitter"

local g_tty_in
if uv.guess_handle(0) == "tty" then
  g_tty_in = assert(uv.new_tty(0, true))
  -- raw mode
  uv.tty_set_mode(g_tty_in, 1)
else
  g_tty_in = assert(uv.new_pipe(false))
  uv.pipe_open(g_tty_in, 0)
end

local stdout
if uv.guess_handle(1) == "tty" then
  stdout = assert(uv.new_tty(1, false))
  -- raw mode
  -- assert(EnableVTMode())
else
  stdout = assert(uv.new_pipe(false))
  uv.pipe_open(stdout, 1)
end

local c = {
  cursor_x = 0,
  cursor_y = 0,
}

local s = Screen.new(uv, stdout)
local left, right = s.root:split_vertical()
s.focus = right
right.callbacks = {
  on_input = function(input)
    local consumed = false
    if input.data == "h" then
      c.cursor_x = c.cursor_x - 1
      consumed = true
    elseif input.data == "j" then
      c.cursor_y = c.cursor_y + 1
      consumed = true
    elseif input.data == "k" then
      c.cursor_y = c.cursor_y - 1
      consumed = true
    elseif input.data == "l" then
      c.cursor_x = c.cursor_x + 1
      consumed = true
    else
    end
    -- clamp
    if c.cursor_x < 0 then
      c.cursor_x = 0
    elseif c.cursor_x >= input.size.width then
      c.cursor_x = input.size.width - 1
    end
    if c.cursor_y < 0 then
      c.cursor_y = 0
    elseif c.cursor_y >= input.size.height then
      c.cursor_y = input.size.height - 1
    end
    return consumed
  end,
  on_render = function(rt, viewport)
    rt:write(
      viewport.y,
      viewport.x,
      ("xy (%d:%d)/(%d:%d)"):format(c.cursor_x, c.cursor_y, viewport.width, viewport.height)
    )
    -- for y = viewport.y, viewport.y + viewport.height - 1 do
    --   rt:write(y, viewport.x, "+")
    -- end
  end,
}

uv.read_start(g_tty_in, function(err, data)
  if err then
    uv.close(g_tty_in)
  elseif data then
    local n = string.byte(data, 1, 1)
    if n == 3 or data == "q" then
      -- ctrl-c
      uv.read_stop(g_tty_in)
    else
      s:input(data)

      local x, y = s.root:get_offset(right)
      s:render(c.cursor_x + x + 1, c.cursor_y + y + 1)
    end
  end
end)

-- ╭─── Live Grep ╮
-- │> round       │
-- ╰──────────────╯

-- ---@param rt RenderTarget
-- function Grid:render(rt, row, col)
--   -- info
-- end
--
-- return Grid

--
-- SIGWINCH
--
--   uv_signal_init(uv_default_loop(), &g_signal_resize);
--   g_signal_resize.data = &r;
--   uv_signal_start(
--       &g_signal_resize,
--       [](uv_signal_t *handle, int signum) {
--         ((Renderer *)handle->data)->onResize();
--       },
--       SIGWINCH);

uv.run()

uv.tty_reset_mode()
