local Screen = require "luatui.Screen"
local SGR = require "luatui.SGR"
local Splitter = require "luatui.Splitter"
---@type uv
local uv = require "luv"

local ICON_MAP = {
  file = " ",
  directory = " ",
  link = "󱞫 ",
}

local s = Screen.make_tty_screen()

---@class Entry
---@field name string
---@field type 'file'|'directory'|'link'

---@class Filer
---@field current string
---@field entries Entry[]
---@field cursor integer
---@field root Splitter
---@field addressbar Splitter
---@field list Splitter
---@field preview Splitter
---@field status Splitter
local Filer = {}
Filer.__index = Filer

---@param dir string?
---@return Filer
function Filer.new(dir)
  local self = setmetatable({
    entries = {},
    cursor = 1,
    root = Splitter.new(),
  }, Filer)

  if dir then
    self:chdir(dir)
  end

  -- layout
  local top, mid, bottom = self.root:split_horizontal({ fix = 1 }, {}, { fix = 1 })

  self.addressbar = top
  self.addressbar.opts.content = function(rt, viewport)
    rt:write(viewport.y, viewport.x, self.current, SGR.bold_on)
  end

  self.status = bottom
  self.status.opts.content = function(rt, viewport)
    if self.dir then
      rt:write(viewport.y, viewport.x, self.dir, SGR.invert_on)
    end
  end

  local l, r = mid:split_vertical({ fix = 24 }, {})
  self.list = l
  self.list.opts.content = function(rt, viewport)
    local i = 1
    for row = viewport.y, viewport.y + viewport.height - 1 do
      local e = self.entries[i]
      if e then
        if not ICON_MAP[e.type] then
          print(e.type)
        end
        local str = ICON_MAP[e.type] .. " " .. e.name
        rt:write(row, 0, str, i == self.cursor and SGR.invert_on or SGR.reset)
      end
      i = i + 1
    end
  end

  self.preview = r

  return self
end

---@param dir string
function Filer:chdir(dir)
  local real = uv.fs_realpath(dir)
  if real then
    dir = real
  end
  local fs = uv.fs_scandir(dir)
  if not fs then
    return
  end

  self.current = dir
  self.entries = {}
  while true do
    local name, type = uv.fs_scandir_next(fs)
    if not name then
      break
    end
    table.insert(self.entries, { name = name, type = type })
  end
end

---@param rt RenderTarget
---@param viewport Viewport
function Filer:render(rt, viewport)
  self.root:render(rt, viewport)
end

---@param ch string
function Filer:input(ch)
  self.last_input = ch
  if ch == "j" then
    self.cursor = self.cursor + 1
  elseif ch == "k" then
    self.cursor = self.cursor - 1
  elseif ch == "h" then
    local basename = self.current:match "[^/\\]+$"
    if basename then
      local dir = self.current:sub(1, #self.current - #basename)
      self.dir = dir
      self:chdir(dir)
    end
  elseif ch == "l" or ch == "\x0d" then
    local e = self.entries[self.cursor]
    if e then
      if e.type == "directory" then
        self:chdir(self.current .. "/" .. e.name)
      end
    end
  end

  if self.cursor < 1 then
    self.cursor = 1
  elseif self.cursor > #self.entries then
    self.cursor = #self.entries
  end
end

local f = Filer.new "."

s.keymap = function(input)
  if f:input(input.data) then
    --
  elseif input.data == "q" then
    return "exit"
  end
end

s.on_render = function(rt, viewport)
  -- 7x5 block
  f:render(rt, viewport)
end

s:run()
