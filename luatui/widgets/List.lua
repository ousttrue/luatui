local SGR = require "luatui.SGR"
local text_util = require "luatui.text_util"

---@class ListOpts
---@field active integer?
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
      active = opts and opts.active or 0,
      scroll = opts and opts.scroll or 0,
      use_sgr = opts and opts.use_sgr or false,
    },
  }, List)
  return self
end

---@return any?
function List:get_active()
  return self.items[self.opts.active + 1]
end

---@param rt RenderTarget
---@param viewport Viewport
function List:render(rt, viewport)
  if self.opts.active < self.opts.scroll then
    self.opts.scroll = self.opts.active
  elseif self.opts.active >= self.opts.scroll + viewport.height - 1 then
    self.opts.scroll = self.opts.active - viewport.height + 1
  end

  local i = self.opts.scroll
  local use_scrolbar = viewport.height < #self.items
  if use_scrolbar then
    -- scroll
    for y = viewport.y, viewport.y + viewport.height - 1 do
      local visible = self:is_visible(viewport, y)
      local item = self.items[i + 1]
      local sgr = SGR.reset
      if item then
        local src = tostring(item)
        src = text_util.padding_right(src, viewport.width - 1, " ") .. (visible and "▒" or "░")
        if self.opts.use_sgr and i == self.opts.active then
          sgr = SGR.invert_on
        end
        rt:write(y, viewport.x, src, sgr)
      else
        local src = text_util.padding_right("", viewport.width - 1, " ") .. (visible and "▒" or "░")
        rt:write(y, viewport.x, src, sgr)
      end
      i = i + 1
    end
  else
    -- without scroll
    for y = viewport.y, viewport.y + viewport.height - 1 do
      local item = self.items[i + 1]
      local src = item and tostring(item) or ""
      src = text_util.padding_right(src, viewport.width, " ")
      local sgr = SGR.reset
      if item and self.opts.use_sgr and i == self.opts.active then
        sgr = SGR.invert_on
      end
      rt:write(y, viewport.x, src, sgr)
      i = i + 1
    end
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

function List:input(ch)
  if ch == "j" then
    self.opts.active = self.opts.active + 1
  elseif ch == "k" then
    self.opts.active = self.opts.active - 1
  end
  if self.opts.active < 0 then
    self.opts.active = 0
  elseif self.opts.active >= #self.items then
    self.opts.active = #self.items - 1
  end
end

return List
