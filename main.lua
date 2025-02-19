print(package.path)

---@type uv
local uv = require "luv"
local win32_util = require "win32_util"

local ESC = "\x1b"
local CSI = "\x1b["

---@class Screen
---@field stdout uv.uv_write_t
---@field width integer
---@field height integer
---@field cursor_x integer
---@field cursor_y integer
local Screen = {}
Screen.__index = Screen

---@param fs uv.uv_write_t
---@return integer width
---@return integer height
local function get_winsize(fs)
  if uv.guess_handle(uv.fileno(fs)) == "tty" then
    local w, h = uv.tty_get_winsize(fs)
    if w and type(h) == "integer" then
      return w, h
    end
  end

  local w, h = win32_util.get_winsize()
  if w and h then
    return w, h
  end

  return 80, 24
end

---@param fs uv.uv_write_t
---@return Screen
function Screen.new(fs)
  local width, height = get_winsize(fs)
  local self = setmetatable({
    stdout = fs,
    width = width,
    height = height,
    cursor_x = width / 2,
    cursor_y = height / 2,
  }, Screen)
  return self
end

---@param src string
function Screen:input(src)
  if src == "h" then
    self.cursor_x = self.cursor_x - 1
  elseif src == "j" then
    self.cursor_y = self.cursor_y + 1
  elseif src == "k" then
    self.cursor_y = self.cursor_y - 1
  elseif src == "l" then
    self.cursor_x = self.cursor_x + 1
  else
  end
  -- clamp
  if self.cursor_x < 0 then
    self.cursor_x = 0
  elseif self.cursor_x >= self.width then
    self.cursor_x = self.width - 1
  end
  if self.cursor_y < 0 then
    self.cursor_y = 0
  elseif self.cursor_y >= self.height then
    self.cursor_y = self.height - 1
  end

  self:render()
end

function Screen:render()
  uv.write(self.stdout, "\x1b[?25l")

  -- clear
  uv.write(self.stdout, CSI .. "1;1H")
  uv.write(self.stdout, CSI .. "2J")
  -- info
  uv.write(self.stdout, CSI .. "1;1H")
  uv.write(self.stdout, ("xy (%d:%d)/(%d:%d)"):format(self.cursor_x, self.cursor_y, self.width, self.height))

  -- cursor
  uv.write(self.stdout, CSI .. ("%d;%dH"):format(self.cursor_y + 1, self.cursor_x + 1))

  uv.write(self.stdout, "\x1b[?25h")
end

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
  stdout = uv.new_pipe(false)
  uv.pipe_open(stdout, 1)
end

local s = Screen.new(stdout)

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
    end
  end
end)

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
