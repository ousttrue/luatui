local Viewport = require "luatui.Viewport"

---@alias KeyCommand 'exit'|nil

---@alias OnInput fun(input:{size: Size, data:string, splitter: Splitter}):KeyCommand
---@alias OnRender fun(rt: RenderTarget, viewport:Viewport)

---@class Callbacks
---@field keymap OnInput
---@field render OnRender

---@class Splitter
---@field callbacks Callbacks?
---@field child_dir 'h'|'v' horizontal or vertical
---@field children Splitter[]
local Splitter = {}
Splitter.__index = Splitter

---@return Splitter
function Splitter.new()
  local self = setmetatable({
    child_dir = "v",
    children = {},
  }, Splitter)
  return self
end

---@param dir 'v'|'h'
---@return Splitter
---@return Splitter
function Splitter:split(dir)
  assert(#self.children == 0)
  self.dir = dir
  local item1 = Splitter.new()
  local item2 = Splitter.new()
  self.children = { item1, item2 }
  return item1, item2
end

---@return Splitter
---@return Splitter
function Splitter:split_vertical()
  return self:split "v"
end

---@return Splitter
---@return Splitter
function Splitter:split_horizontal()
  return self:split "h"
end

local function fill(str, n)
  local indent = ""
  for _ = 1, n do
    indent = indent .. str
  end
  return indent
end

---@param rt RenderTarget
---@param  viewport Viewport
---@param level integer?
function Splitter:render(rt, viewport, level)
  level = level or 0
  if #self.children == 0 then
    -- print(viewport)
    for y = viewport.y, viewport.y + viewport.height - 1 do
      rt:write(y, viewport.x, fill(" ", viewport.width))
    end
  elseif #self.children == 1 then
    assert(false, "#self.children == 1")
  else
    if self.dir == "v" then
      local bn = #self.children - 1
      local x = 0
      local child_size = math.floor((viewport.height - bn) / #self.children)
      for i, child in ipairs(self.children) do
        if i > 1 then
          rt:vertical_line(x, viewport.y, viewport.height)
          x = x + 1
        end
        local child_viewport =
          Viewport.new(x, viewport.y, i ~= #self.children and child_size or viewport.height - x, viewport.height)
        child:render(rt, child_viewport, level + 1)
        x = x + child_size
      end
    elseif self.dir == "h" then
      local bn = #self.children - 1
      local y = 0
      local child_size = math.floor((viewport.height - bn) / #self.children)
      for i, child in ipairs(self.children) do
        if i > 1 then
          --- border
          rt:write(y, viewport.x, "---")
          y = y + 1
        end
        local child_viewport =
          Viewport.new(viewport.x, y, viewport.width, i ~= #self.children and child_size or viewport.height - y)
        child:render(rt, child_viewport, level + 1)
        y = y + child_size
      end
    else
    end
  end
end

---@param target Splitter
---@return integer? offset_x
---@return integer? offset_y
function Splitter:get_offset(target)
  if self == target then
    return 0, 0
  end

  local offset = 0
  for _, child in ipairs(self.children) do
    local x, y = child:get_offset(target)
    if x and y then
      if self.dir == "v" then
        return offset + x, y
      elseif self.dir == "h" then
        return x, offset + y
      end
    end
    if self.dir == "v" then
      offset = offset + child.current_size.width
    elseif self.dir == "h" then
      offset = offset + child.current_size.height
    end
  end
end

return Splitter
