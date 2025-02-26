---@type uv
local uv = require "luv"
local Computar = require "luatui.fs.Computar"
local Entry = require "luatui.fs.Entry"

---@class Directory
---@field path string
---@field entries Entry[]
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
  }, Directory)

  local fs = uv.fs_scandir(path)
  if fs then
    while true do
      local name, type = uv.fs_scandir_next(fs)
      if not name then
        break
      end
      table.insert(self.entries, Entry.new(name, type))
    end
  end

  return self
end

function Directory:__tostring()
  return self.path
end

---@return Directory|Computar
---@return integer?
function Directory:get_parent()
  local basename = self.path:match "[^/\\]+$"
  if basename then
    local dir_path = self.path:sub(1, #self.path - #basename)
    local dir = Directory.new(dir_path)
    local selected
    for i, e in ipairs(dir.entries) do
      local real = uv.fs_realpath(dir_path .. "/" .. e.name)
      if real == self.path then
        selected = (i - 1)
        break
      end
    end
    return dir, selected
  else
    return Computar.new()
  end
end

---@paramter e Entry
---@return Directory?
function Directory:goto(e)
  if e.type == "directory" then
    return Directory.new(self.path .. "/" .. e.name)
  end
end

return Directory
