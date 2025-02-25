---@type uv
local uv = require "luv"
local win32_util = require "luatui.win32_util"

---@class Directory
---@field path string
---@field entries Entry[]
---@field selected integer
local Directory = {}
Directory.__index = Directory

---@param path string
function Directory.new(path)
  local real = uv.fs_realpath(path)
  if real then
    path = real
  end

  local self = setmetatable({
    path = path,
    entries = {},
    selected = 1,
  }, Directory)

  local fs = uv.fs_scandir(path)
  if fs then
    while true do
      local name, type = uv.fs_scandir_next(fs)
      if not name then
        break
      end
      table.insert(self.entries, { name = name, type = type })
    end
  end

  return self
end

function Directory:__tostring()
  return self.path
end

---@return Directory|Computar
function Directory:get_parent()
  local basename = self.path:match "[^/\\]+$"
  if basename then
    local dir_path = self.path:sub(1, #self.path - #basename)
    local dir = Directory.new(dir_path)
    for i, e in ipairs(dir.entries) do
      local real = uv.fs_realpath(dir_path .. "/" .. e.name)
      if real == self.path then
        dir.selected = i
        break
      end
    end
    return dir
  else
    return win32_util.Computar.new()
  end
end

---@paramter e Entry
---@return Directory?
function Directory:goto(e)
  if e.type == "directory" then
    return Directory.new(self.path .. "/" .. e.name)
  end
end

function Directory:input(ch)
  if ch == "j" then
    self.selected = self.selected + 1
  elseif ch == "k" then
    self.selected = self.selected - 1
  end
  if self.selected < 1 then
    self.selected = 1
  elseif self.selected > #self.entries then
    self.selected = #self.entries
  end
end

return Directory
