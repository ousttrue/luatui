---@class Grid
---@field rows integer
---@field cols integer
---@field cursor_x integer
---@field cursor_y integer
local Grid = {}
Grid.__index = Grid

---@return Grid
function Grid.new(rows, cols)
  local self = setmetatable({
    rows = rows,
    cols = cols,
    cursor_x = 0,
    cursor_y = 0,
  }, Grid)
  return self
end

---@param target Grid
---@return integer? offset_x
---@return integer? offset_y
function Grid:get_offset(target)
  if target == self then
    return 0, 0
  end
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

return Grid
