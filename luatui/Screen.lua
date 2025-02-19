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
---@field splitter Splitter
---@field focus? Grid
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
    splitter = Splitter.new(width, height),
  }, Screen)

  local content = self.splitter.contents[1]
  ---@cast content Grid
  self.focus = content

  self:render()
  return self
end

---@param src string
function Screen:input(src)
  self.splitter:input(src)
  self:render()
end

function Screen:render()
  -- hide cursor
  self.uv.write(self.out, "\x1b[?25l")
  -- clear
  self.uv.write(self.out, "\x1b[1;1H")
  self.uv.write(self.out, "\x1b[2J")

  -- content
  local rt = RenderTarget.new()
  self.splitter:render(rt)
  flush(self.uv, self.out, rt, self.splitter.height)

  -- cursor
  if self.focus then
    local x, y = self.splitter:get_offset(self.focus)
    self.uv.write(self.out, ("\x1b[%d;%dH"):format(self.focus.cursor_y + y + 1, self.focus.cursor_x + x + 1))
  end

  -- show cursor
  self.uv.write(self.out, "\x1b[?25h")
end

return Screen
