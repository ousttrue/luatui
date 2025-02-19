local win32_util = require "luatui.win32_util"
local Splitter = require "luatui.Splitter"
local RenderTarget = require "luatui.RenderTarget"

---@param uv uv
---@param out uv.uv_write_t
---@return integer width
---@return integer height
local function get_winsize(uv, out)
  if uv.guess_handle(assert(uv.fileno(out))) == "tty" then
    local w, h = uv.tty_get_winsize(out)
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

---@param uv uv
---@param out uv.uv_write_t
---@param rt RenderTarget
local function flush(uv, out, rt, rows)
  for i = 0, rows - 1 do
    local line = rt:get_line(i)
    if line then
      uv.write(out, ("\x1b[%d;1H%s"):format(i + 1, line))
    end
  end
end

---@class Screen
---@field uv uv
---@field out uv.uv_write_t
---@field root Splitter
---@field focus Splitter?
local Screen = {}
Screen.__index = Screen

---@param uv uv
---@param out uv.uv_write_t
---@return Screen
function Screen.new(uv, out)
  local width, height = get_winsize(uv, out)
  local self = setmetatable({
    uv = uv,
    out = out,
    root = Splitter.new(width, height),
  }, Screen)
  self:render()
  return self
end

---@param src string
function Screen:input(src)
  if self.focus and self.focus.callbacks then
    self.focus.callbacks.on_input {
      size = self.focus.current_size,
      data = src,
    }
  else
    self.root:input(src)
  end
end

function Screen:render(cursor_x, cursor_y)
  -- hide cursor
  self.uv.write(self.out, "\x1b[?25l")
  -- clear
  self.uv.write(self.out, "\x1b[1;1H")
  self.uv.write(self.out, "\x1b[2J")

  -- content
  local rt = RenderTarget.new()
  self.root:render(rt)
  flush(self.uv, self.out, rt, self.root.current_size.height)

  -- cursor
  if self.focus then
    self.uv.write(self.out, ("\x1b[%d;%dH"):format(cursor_y, cursor_x))
    -- show cursor
    self.uv.write(self.out, "\x1b[?25h")
  end
end

return Screen
