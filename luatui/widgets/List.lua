local SGR = require "luatui.SGR"
local text_util = require "luatui.text_util"

---@class ListOpts
---@field selected integer?
---@field scroll integer?
---@field use_sgr boolean?

---@class List
---@field items any[]
---@field opts ListOpts
local List = {}
List.__index = List

---@param items any[]
---@param opts ListOpts?
---@return List
function List.new(items, opts)
  local self = setmetatable({
    items = items,
    opts = {
      selected = opts and opts.selected or 1,
      scroll = opts and opts.scroll or 1,
      use_sgr = opts and opts.use_sgr or false,
    },
  }, List)
  return self
end

---@param rt RenderTarget
---@param viewport Viewport
function List:render(rt, viewport)
  local i = self.opts.scroll
  for y = viewport.y, viewport.y + viewport.height - 1 do
    local item = self.items[i]

    local src = item and tostring(item) or ""
    src = text_util.padding_right(src, viewport.width, " ")

    local sgr = self.opts.use_sgr and (i == self.opts.selected and SGR.invert_on or SGR.reset) or SGR.reset

    rt:write(y, viewport.x, src, sgr)
    i = i + 1
  end
end

return List
