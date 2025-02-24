local Viewport = require "luatui.Viewport"

---@alias KeyCommand 'exit'|nil

---@alias OnInput fun(input:{size: Size, data:string, splitter: Splitter}):KeyCommand
---@alias OnRender fun(rt: RenderTarget, viewport:Viewport)

---@class Callbacks
---@field keymap OnInput
---@field render OnRender

---@class SplitterOpts
---@field grow true?
---@field fix integer?

---@class Splitter
---@field callbacks Callbacks?
---@field child_dir 'h'|'v' horizontal or vertical
---@field children Splitter[]
---@field opts SplitterOpts
local Splitter = {}
Splitter.__index = Splitter

---@param opts SplitterOpts?
---@return Splitter
function Splitter.new(opts)
  local self = setmetatable({
    child_dir = "v",
    children = {},
    opts = opts or { grow = true },
  }, Splitter)
  return self
end

---@param dir 'v'|'h'
---@param ... SplitterOpts[]
---@return Splitter
---@return ...
function Splitter:split(dir, ...)
  self.dir = dir

  self.children = {}
  for _, opts in ipairs { ... } do
    local child = Splitter.new(opts)
    table.insert(self.children, child)
  end

  return unpack(self.children)
end

---@param ... SplitterOpts[]
---@return Splitter
---@return Splitter
function Splitter:split_vertical(...)
  return self:split("v", ...)
end

---@param ... SplitterOpts[]
---@return Splitter
---@return Splitter
function Splitter:split_horizontal(...)
  return self:split("h", ...)
end

local function fill(str, n)
  local indent = ""
  for _ = 1, n do
    indent = indent .. str
  end
  return indent
end

---@class RenderOpts
---@field h string?
---@field v string?

---@param rt RenderTarget
---@param  viewport Viewport
---@param opts RenderOpts?
function Splitter:render(rt, viewport, opts)
  opts = opts or {}
  opts.h = opts.h or "-"
  opts.v = opts.v or "|"

  if #self.children == 0 then
    -- print(viewport)
    for y = viewport.y, viewport.y + viewport.height - 1 do
      rt:write(y, viewport.x, fill(" ", viewport.width))
    end
  elseif #self.children == 1 then
    assert(false, "#self.children == 1")
  else
    if self.dir == "v" then
      -- vertical
      -- +---+
      -- | | |
      -- +---+
      local grow_child_count = 0
      local bn = #self.children - 1
      local remain_size = viewport.width - bn
      for _, child in ipairs(self.children) do
        if child.opts.fix then
          remain_size = remain_size - child.opts.fix
        else
          grow_child_count = grow_child_count + 1
        end
      end
      local grow_child_size = 0
      if grow_child_count > 0 then
        grow_child_size = math.floor(remain_size / grow_child_count)
      end

      local x = 0
      for i, child in ipairs(self.children) do
        if i > 1 then
          rt:vertical_line(x, viewport.y, viewport.height, opts)
          x = x + 1
        end
        local w
        if i < #self.children then
          if child.opts.fix then
            w = child.opts.fix
          else
            w = grow_child_size
          end
        else
          -- last
          w = viewport.width - x
        end

        local child_viewport = Viewport.new(x, viewport.y, w, viewport.height)
        child:render(rt, child_viewport)
        x = x + w
      end
    elseif self.dir == "h" then
      -- horizontal
      -- +---+
      -- +---+
      -- +---+
      local grow_child_count = 0
      local bn = #self.children - 1
      local remain_size = viewport.height - bn
      for _, child in ipairs(self.children) do
        if child.opts.fix then
          remain_size = remain_size - child.opts.fix
        else
          grow_child_count = grow_child_count + 1
        end
      end
      local grow_child_size = 0
      if grow_child_count > 0 then
        grow_child_size = math.floor(remain_size / grow_child_count)
      end

      local y = 0
      for i, child in ipairs(self.children) do
        if i > 1 then
          --- border
          rt:write(y, viewport.x, fill(opts.h, viewport.width))
          y = y + 1
        end
        local h
        if i < #self.children then
          if child.opts.fix then
            h = child.opts.fix
          else
            h = grow_child_size
          end
        else
          --last
          h = viewport.height - y
        end
        local child_viewport = Viewport.new(viewport.x, y, viewport.width, h)
        child:render(rt, child_viewport)
        y = y + h
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
