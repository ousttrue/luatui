local win32_util = require "luatui.win32_util"

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

---@class Screen
---@field uv uv
---@field out uv.uv_write_t
---@field width integer
---@field height integer
---@field cursor_x integer
---@field cursor_y integer
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
  self.uv.write(self.out, "\x1b[?25l")

  -- clear
  self.uv.write(self.out, "\x1b[1;1H")
  self.uv.write(self.out, "\x1b[2J")
  -- info
  self.uv.write(self.out, "\x1b[1;1H")
  self.uv.write(self.out, ("xy (%d:%d)/(%d:%d)"):format(self.cursor_x, self.cursor_y, self.width, self.height))

  -- cursor
  self.uv.write(self.out, ("\x1b[%d;%dH"):format(self.cursor_y + 1, self.cursor_x + 1))

  self.uv.write(self.out, "\x1b[?25h")
end

return Screen
