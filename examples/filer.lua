local Screen = require "luatui.Screen"
local SGR = require "luatui.SGR"
local Splitter = require "luatui.Splitter"
local Directory = require "luatui.Directory"
local List = require "luatui.widgets.List"

---@type uv
local uv = require "luv"

local s = Screen.make_tty_screen()

---@class Filer
---@field current Directory|Computar
---@field list List
---@field root Splitter
---@field addressbar Splitter
---@field left Splitter
---@field preview Splitter
---@field status Splitter
local Filer = {}
Filer.__index = Filer

---@param dir string
---@return Filer
function Filer.new(dir)
  local self = setmetatable({
    entries = {},
    root = Splitter.new(),
  }, Filer)
  self:set_dir(Directory.new(dir))

  -- layout
  local top, mid, bottom = self.root:split_horizontal({ fix = 1 }, {}, { fix = 1 })

  self.addressbar = top
  self.addressbar.opts.content = function(rt, viewport)
    rt:write(viewport.y, viewport.x, tostring(self.current), SGR.bold_on)
  end

  self.status = bottom
  self.status.opts.content = function(rt, viewport)
    if self.tmp then
      rt:write(viewport.y, viewport.x, self.tmp, SGR.invert_on)
    end
  end

  local l, r = mid:split_vertical({ fix = 24 }, {})
  self.left = l
  self.left.opts.content = function(rt, viewport)
    self.tmp = ("%d/%d, scroll=%d"):format(self.list.opts.selected, #self.current.entries, self.list.opts.scroll)
    self.list:render(rt, viewport)
  end

  self.preview = r

  return self
end

---@param dir Directory|Computar
---@param selected integer?
function Filer:set_dir(dir, selected)
  self.current = dir
  -- self.list = List.new(self.current.entries)
  self.list = List.new(self.current.entries, {
    selected = selected,
    use_sgr = true,
  })
end

---@param rt RenderTarget
---@param viewport Viewport
function Filer:render(rt, viewport)
  self.root:render(rt, viewport)
end

---@param ch string
function Filer:input(ch)
  if self.list:input(ch) then
    --
  elseif ch == "h" then
    local parent, selected = self.current:get_parent()
    if parent then
      self:set_dir(parent, selected)
    end
  elseif ch == "l" or ch == "\x0d" then
    local e = self.current.entries[self.list.opts.selected + 1]
    if e then
      local dir = self.current:goto(e)
      if dir then
        self:set_dir(dir)
      end
    end
  end
end

local f = Filer.new "."

local function set_interval(interval, callback)
  local timer = uv.new_timer()
  local function ontimeout()
    -- p("interval", timer)
    callback(timer)
  end
  uv.timer_start(timer, interval, interval, ontimeout)
  return timer
end

local i = set_interval(300, function()
  s:render()
end)

local function clear_timeout(timer)
  uv.timer_stop(timer)
  uv.close(timer)
end

s.keymap = function(input)
  if f:input(input.data) then
    --
  elseif input.data == "q" then
    clear_timeout(i)
    return "exit"
  end
end

s.on_render = function(rt, viewport)
  -- 7x5 block
  f:render(rt, viewport)
end

s:render()

s:run()
