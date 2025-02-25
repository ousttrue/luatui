local SGR = require "luatui.SGR"

---@class List
---@field items any[]
local List = {}
List.__index = List

---@param items any[]
---@return List
function List.new(items)
  local self = setmetatable({
    items = { unpack(items) },
  }, List)
  return self
end

---@param rt RenderTarget
---@param viewport Viewport
---@param selected integer?
function List:render(rt, viewport, selected)
  local i = 1
  for y = viewport.y, viewport.y + viewport.height - 1 do
    local item = self.items[i]
    if item then
      rt:write(y, viewport.x, tostring(item), i == selected and SGR.invert_on or SGR.reset)
    end
    i = i + 1
  end
end

return List
