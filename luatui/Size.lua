---@class Size
---@field width integer
---@field height integer
local Size = {}
Size.__index = Size

---@param width integer
---@param height integer
---@return Size
function Size.new(width, height)
  local self = setmetatable({
    width = width,
    height = height,
  }, Size)
  return self
end

return Size
