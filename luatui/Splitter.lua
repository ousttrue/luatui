local Grid = require "luatui.Grid"

---@class Splitter
---@field width integer
---@field height integer
---@field dir 'h'|'v' horizontal or vertical
---@field children Splitter[]
---@field grid Grid?
local Splitter = {}
Splitter.__index = Splitter

---@param dir 'h'|'v'|nil
---@return Splitter
function Splitter.new(width, height, dir)
  local self = setmetatable({
    width = width,
    height = height,
    dir = dir or "h",
    children = {},
    grid = Grid.new(height, width),
  }, Splitter)
  return self
end

---@return Splitter
function Splitter:split_vertical()
  self.dir = "v"
  if #self.children == 0 then
    -- move grid to 1st child
    table.insert(self.children, Splitter.new(self.grid))
    self.grid = nil
  end

  local new_child = Splitter.new()
  table.insert(self.children, new_child)
  return new_child
end

---@param src string
---@return boolean consumed
function Splitter:input(src)
  if self.grid then
    return self.grid:input(src)
  else
    for _, child in ipairs(self.children) do
      local consumed = child:input(src)
      return consumed
    end
    return false
  end
end

---@param rt RenderTarget
---@return integer? offset_x
---@return integer? offset_y
function Splitter:render(rt, offset_x, offset_y)
  if not offset_x then
    offset_x = 0
  end
  if not offset_y then
    offset_y = 0
  end

  if self.grid then
    self.grid:render(rt, offset_y, offset_x)
  else
    local offset = 0
    for _, child in ipairs(self.children) do
      if self.dir == "v" then
        child:render(rt, offset_x + offset, offset_y)
        offset = offset + child.width
      elseif self.dir == "h" then
        child:render(rt, offset_x, offset_y + offset)
        offset = offset + child.height
      end
    end
  end
end

---@param grid Grid
---@return integer? offset_x
---@return integer? offset_y
function Splitter:get_offset(grid)
  if self.grid == grid then
    return 0, 0
  end

  local offset = 0
  for _, child in ipairs(self.children) do
    local x, y
    if self.dir == "v" then
      x, y = child:get_offset(grid)
    elseif self.dir == "h" then
      x, y = child:get_offset(grid)
    end
    if x and y then
      if self.dir == "v" then
        return offset + x, y
      elseif self.dir == "h" then
        return x, offset + y
      end
    end
    if self.dir == "v" then
      offset = offset + child.width
    elseif self.dir == "h" then
      offset = offset + child.height
    end
  end
  -- assert(false)
  return 0, 0
end

return Splitter
