---@class Viewport
---@field x integer
---@field y integer
---@field width integer
---@field height integer
local Viewport = {}
Viewport.__index = Viewport

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@return Viewport
function Viewport.new(x, y, width, height)
  assert(x)
  assert(y)
  assert(width)
  assert(height)
  local self = setmetatable({
    x = x,
    y = y,
    width = width,
    height = height,
  }, Viewport)
  return self
end

---@param width integer
---@param height integer
---@return Viewport
function Viewport.from_size(width, height)
  return Viewport.new(0, 0, width, height)
end

function Viewport:__tostring()
  return ("{x=%d,y=%d,w=%d,h=%d}"):format(self.x, self.y, self.width, self.height)
end

return Viewport
