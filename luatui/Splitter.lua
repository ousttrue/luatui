local Grid = require "luatui.Grid"

---@class Splitter
---@field width integer
---@field height integer
---@field dir 'h'|'v' horizontal or vertical
---@field contents (Splitter|Grid)[]
local Splitter = {}
Splitter.__index = Splitter

---@param dir 'h'|'v'|nil
---@return Splitter
function Splitter.new(width, height, dir)
  local self = setmetatable({
    width = width,
    height = height,
    dir = dir or "h",
    contents = { Grid.new(height, width) },
  }, Splitter)
  return self
end

---@param src string
---@return boolean consumed
function Splitter:input(src)
  for _, content in ipairs(self.contents) do
    local consumed = content:input(src)
    return consumed
  end
  return false
end

---@param rt RenderTarget
function Splitter:render(rt)
  for _, content in ipairs(self.contents) do
    content:render(rt)
  end
end

---@param target Grid
---@return integer? offset_x
---@return integer? offset_y
function Splitter:get_offset(target)
  local offset = 0
  for _, content in ipairs(self.contents) do
    local x, y = content:get_offset(target)
    if x and y then
      if self.dir == "v" then
        return offset + x, y
      elseif self.dir == "h" then
        return x, offset + y
      end
    end
    if self.dir == "v" then
      offset = offset + content.width
    elseif self.dir == "h" then
      offset = offset + content.height
    end
  end
  assert(false)
end

return Splitter
