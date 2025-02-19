local Size = require "luatui.Size"

---@alias OnInput fun(splitter: Splitter, input:{size: Size, data:string}):boolean
---@alias OnRender fun(rt: RenderTarget, viewport:{x:integer, y:integer, width:integer, height:integer})

---@class Callbacks
---@field keymap OnInput
---@field render OnRender

---@class Splitter
---@field current_size Size
---@field callbacks Callbacks?
---@field child_dir 'h'|'v' horizontal or vertical
---@field children Splitter[]
local Splitter = {}
Splitter.__index = Splitter

---@param width integer
---@param height integer
---@return Splitter
function Splitter.new(width, height)
  local self = setmetatable({
    current_size = Size.new(width, height),
    child_dir = "v",
    children = {},
  }, Splitter)
  return self
end

---@return Splitter
---@return Splitter
function Splitter:split_vertical()
  self.dir = "v"
  local item1 = Splitter.new(self.current_size.width / 2, self.current_size.height)
  if self.callbacks then
    item1.callbacks = self.callbacks
    self.callbacks = nil
  end
  local item2 = Splitter.new(self.current_size.width / 2, self.current_size.height)
  self.children = { item1, item2 }
  return item1, item2
end

---@param src string
---@return boolean consumed
function Splitter:process_input(src)
  if self.callbacks then
    return self.callbacks.keymap(self, { size = self.current_size, src = src })
  else
    for _, child in ipairs(self.children) do
      local consumed = child:process_input(src)
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

  if self.callbacks then
    self.callbacks.render(rt, {
      y = offset_y,
      x = offset_x,
      width = self.current_size.width,
      height = self.current_size.height,
    })
  else
    local offset = 0
    for _, child in ipairs(self.children) do
      if self.dir == "v" then
        child:render(rt, offset_x + offset, offset_y)
        offset = offset + child.current_size.width
      elseif self.dir == "h" then
        child:render(rt, offset_x, offset_y + offset)
        offset = offset + child.current_size.height
      end
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
