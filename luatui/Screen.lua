local win32_util = require "luatui.win32_util"
local RenderTarget = require "luatui.RenderTarget"
local Viewport = require "luatui.Viewport"

---@param uv uv
---@param output uv.uv_write_t
---@return integer width
---@return integer height
local function get_winsize(uv, output)
  if uv.guess_handle(assert(uv.fileno(output))) == "tty" then
    local w, h = uv.tty_get_winsize(output)
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

local last_write = {}

---@param uv uv
---@param output uv.uv_write_t
---@param rt RenderTarget
local function flush(uv, output, rt, rows)
  -- for i = 1, rows do
  for i, line in rt:render() do
    if line then
      local last = last_write[i]
      if last ~= line then
        -- ESC [ <n> K
        uv.write(output, ("\x1b[%d;1H%s\x1b[K"):format(i, line))
        last_write[i] = line
      end
    end
  end
end

---@class Screen
---@field uv uv
---@field viewport Viewport
---@field output uv.uv_write_t
---@field input uv.uv_stream_t
---@field keymap fun(input):KeyCommand
---@field on_render fun(rt: RenderTarget, viewport:Viewport)?
---@field on_end_frame fun()?
local Screen = {}
Screen.__index = Screen

---@param uv uv
---@param output uv.uv_write_t
---@return Screen
function Screen.new(uv, output, input)
  local width, height = get_winsize(uv, output)
  local self = setmetatable({
    uv = uv,
    viewport = Viewport.from_size(width, height),
    output = output,
    input = input,
  }, Screen)
  self:clear()
  self:render()
  return self
end

function Screen:clear()
  self.uv.write(self.output, "\x1b[1;1H")
  self.uv.write(self.output, "\x1b[2J")
end

---@return Screen
function Screen.make_tty_screen()
  local uv = require "luv"

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

  local s = Screen.new(uv, stdout, g_tty_in)
  return s
end

function Screen:run()
  self.uv.read_start(self.input, function(err, data)
    if err then
      self.uv.close(self.input)
    elseif data then
      local keycommand
      if self.keymap then
        keycommand = self.keymap {
          viewport = self.viewport,
          data = data,
        }
      end
      self:render()
      if self.on_end_frame then
        self.on_end_frame()
      end
      if keycommand == "exit" then
        self.uv.read_stop(self.input)
      end
    end
  end)

  self.uv.run()

  self.uv.tty_reset_mode()
end

---@param x 0 origin
---@param y 0 origin
function Screen:show_cursor(x, y)
  self.uv.write(self.output, ("\x1b[%d;%dH"):format(y + 1, x + 1))
  -- show cursor
  self.uv.write(self.output, "\x1b[?25h")
end

function Screen:render()
  -- hide cursor
  self.uv.write(self.output, "\x1b[?25l")
  -- clear mode
  self.uv.write(self.output, "\x1b[1;1H")
  self.uv.write(self.output, "\x1b[0m")

  -- content
  if self.on_render then
    local rt = RenderTarget.new()
    self.on_render(rt, self.viewport)
    flush(self.uv, self.output, rt, self.viewport.height)
  end
end

return Screen
