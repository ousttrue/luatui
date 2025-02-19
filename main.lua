---@type uv
local uv = require "luv"
local Screen = require "luatui.Screen"

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

---@class Cursor
---@field cursor_x integer
---@field cursor_y integer
local Cursor = {}
Cursor.__index = Cursor

---@return Cursor
function Cursor.new()
  local self = setmetatable({
    cursor_x = 0,
    cursor_y = 0,
  }, Cursor)
  return self
end

function Cursor:input(input)
  local consumed = false
  if input.data == "h" then
    self.cursor_x = self.cursor_x - 1
    consumed = true
  elseif input.data == "j" then
    self.cursor_y = self.cursor_y + 1
    consumed = true
  elseif input.data == "k" then
    self.cursor_y = self.cursor_y - 1
    consumed = true
  elseif input.data == "l" then
    self.cursor_x = self.cursor_x + 1
    consumed = true
  else
  end
  -- clamp
  if self.cursor_x < 0 then
    self.cursor_x = 0
  elseif self.cursor_x >= input.size.width then
    self.cursor_x = input.size.width - 1
  end
  if self.cursor_y < 0 then
    self.cursor_y = 0
  elseif self.cursor_y >= input.size.height then
    self.cursor_y = input.size.height - 1
  end
  return consumed
end

function Cursor:label(viewport)
  return ("xy (%d:%d)/(%d:%d)"):format(self.cursor_x, self.cursor_y, viewport.width, viewport.height)
end

local s = Screen.new(uv, stdout)
local left, right = s.root:split_vertical()
s.focus = right

local function tab_function(input)
  if input.data == "\t" then
    s.focus = (s.focus == right) and left or right
    return true
  end
end

local function make_callbacks(c)
  return {
    keymap = function(splitter, input)
      if c:input(input) then
        return true
      end
      if tab_function(input) then
        return true
      end
      return false
    end,
    on_render = function(rt, viewport)
      rt:write(viewport.y, viewport.x, c:label(viewport))
    end,
  }
end

local left_cursor = Cursor.new()
left.callbacks = make_callbacks(left_cursor)
local right_cursor = Cursor.new()
right.callbacks = make_callbacks(right_cursor)

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

      local x, y = s.root:get_offset(s.focus)

      local c = s.focus == right and right_cursor or left_cursor
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
