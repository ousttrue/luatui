---@class Grid
---@field rows integer
---@field cols integer
---@field cursor_x integer
---@field cursor_y integer
local Grid = {}
Grid.__index = Grid

---@return Grid
function Grid.new()
  local self = setmetatable({}, Grid)
  return self
end

---@param src string
---@return boolean consumed
function Grid:input(src)
  local consumed = false
  if src == "h" then
    self.cursor_x = self.cursor_x - 1
    consumed = true
  elseif src == "j" then
    self.cursor_y = self.cursor_y + 1
    consumed = true
  elseif src == "k" then
    self.cursor_y = self.cursor_y - 1
    consumed = true
  elseif src == "l" then
    self.cursor_x = self.cursor_x + 1
    consumed = true
  else
  end
  -- clamp
  if self.cursor_x < 0 then
    self.cursor_x = 0
  elseif self.cursor_x >= self.cols then
    self.cursor_x = self.cols - 1
  end
  if self.cursor_y < 0 then
    self.cursor_y = 0
  elseif self.cursor_y >= self.rows then
    self.cursor_y = self.rows - 1
  end
  return consumed
end

---@param rt RenderTarget
function Grid:render(rt)
  -- info
  rt:write(0, 0, ("xy (%d:%d)/(%d:%d)"):format(self.cursor_x, self.cursor_y, self.cols, self.rows))
end

---@class Splitter
---@field width integer
---@field height integer
---@field dir 'h'|'v' horizontal or vertical
---@field content Grid|Splitter|nil
local Splitter = {}
Splitter.__index = Splitter

---@param dir 'h'|'v'|nil
---@return Splitter
function Splitter.new(width, height, dir)
  local self = setmetatable({
    width = width,
    height = height,
    dir = dir or "h",
  }, Splitter)
  return self
end

---@param src string
---@return boolean consumed
function Splitter:input(src)
  if self.content then
    local consumed = self.content:input(src)
    return consumed
  end
  return false
end

---@param rt RenderTarget
function Splitter:render(rt)
  if self.content then
    self.content:render(rt)
  end
end

---@return Grid?
---@return integer? offset_x
---@return integer? offset_y
function Splitter:get_focus() end

return Splitter
