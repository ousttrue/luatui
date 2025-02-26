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
      selected = opts and opts.selected or 0,
      scroll = opts and opts.scroll or 0,
      use_sgr = opts and opts.use_sgr or false,
    },
  }, List)
  return self
end

---@param rt RenderTarget
---@param viewport Viewport
function List:render(rt, viewport)
  local i = self.opts.scroll
  local use_scrolbar = viewport.height < #self.items
  for y = viewport.y, viewport.y + viewport.height - 1 do
    local item = self.items[i + 1]

    local src = item and tostring(item) or ""
    if use_scrolbar then
      local visible = self:is_visible(viewport, y)
      src = text_util.padding_right(src, viewport.width - 1, " ") .. (visible and "▒" or "░")
    else
      src = text_util.padding_right(src, viewport.width, " ")
    end

    local sgr = self.opts.use_sgr and (i == self.opts.selected and SGR.invert_on or SGR.reset) or SGR.reset

    rt:write(y, viewport.x, src, sgr)
    i = i + 1
  end
end

-- items=4, height:3, y=0, scroll=1 =>false
-- items=4, height:3, y=1, scroll=1 =>true
-- items=4, height:3, y=2, scroll=1 =>true
--
-- items=4, height:3, y=0, scroll=0 =>true
-- items=4, height:3, y=1, scroll=0 =>true
-- items=4, height:3, y=2, scroll=0 =>false
--
---@param viewport Viewport
---@param y integer
---@return boolean
function List:is_visible(viewport, y)
  local under = (y - viewport.y) / viewport.height
  local min = self.opts.scroll / #self.items
  if under < min then
    return false
  end

  local heigher = (y + 1 - viewport.y) / viewport.height
  local max = (self.opts.scroll + viewport.height) / #self.items
  -- print(heigher, max)
  if heigher > max then
    return false
  end
  return true
end

return List
