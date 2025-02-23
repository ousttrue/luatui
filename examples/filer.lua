local Screen = require "luatui.Screen"
local SGR = require "luatui.SGR"
---@type uv
local uv = require "luv"

local ICON_MAP = {
  file = " ",
  directory = " ",
}

local s = Screen.make_tty_screen()

---@class Entry
---@field name string
---@field type 'file'|'directory'

---@class Filer
---@field entries Entry[]
---@field cursor integer
local Filer = {}
Filer.__index = Filer

---@return Filer
function Filer.new()
  local self = setmetatable({
    --
    entries = {},
    cursor = 1,
  }, Filer)

  return self
end

---@param dir string
function Filer:chdir(dir)
  self.entries = {}
  local fs = uv.fs_scandir(dir)
  if not fs then
    return
  end

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
  local i = 0
  for row = viewport.y, viewport.y + viewport.height - 1 do
    local e = self.entries[i]
    if e then
      local str = ICON_MAP[e.type] .. " " .. e.name
      rt:write(row, 0, str, row == self.cursor and SGR.invert_on or SGR.reset)
    end
    i = i + 1
  end
end

---@param ch string
function Filer:input(ch)
  if ch == "j" then
    self.cursor = self.cursor + 1
  elseif ch == "k" then
    self.cursor = self.cursor - 1
  end

  if self.cursor < 1 then
    self.cursor = 1
  elseif self.cursor > #self.entries then
    self.cursor = #self.entries
  end
end

local f = Filer.new()
f:chdir "."

s.root.callbacks = {
  keymap = function(input)
    if f:input(input.data) then
      --
    elseif input.data == "q" then
      return "exit"
    end
  end,
  render = function(rt, viewport)
    -- 7x5 block
    f:render(rt, viewport)
  end,
}

s:run()
