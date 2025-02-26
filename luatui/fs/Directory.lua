---@type uv
local uv = require "luv"
local Computar = require "luatui.fs.Computar"
local Entry = require "luatui.fs.Entry"

---@class Directory
---@field path string
---@field entries Entry[]
---@field parent? Directory|Computar
local Directory = {}
Directory.__index = Directory

---@param path string
---@param parent Directory|Computar|nil
---@return Directory
function Directory.new(path, parent)
  local real = uv.fs_realpath(path)
  if real then
    path = real
  end

  local self = setmetatable({
    path = path,
    entries = {},
    parent = parent,
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
    table.sort(self.entries, function(a, b)
      if a.type == b.type then
        return a.name:upper() < b.name:upper()
      else
        if a.type == "directory" then
          return true
        else
          return false
        end
      end
    end)
  end

  return self
end

function Directory:__tostring()
  return self.path
end

---@return Directory|Computar
---@return integer?
function Directory:get_parent()
  if self.parent then
    return self.parent
  end

  local basename = self.path:match "[^/\\]+$"
  if basename then
    local dir_path = self.path:sub(1, #self.path - #basename)
    local dir = Directory.new(dir_path)
    local self_element
    for i, e in ipairs(dir.entries) do
      local real = uv.fs_realpath(dir_path .. "/" .. e.name)
      if real == self.path then
        self_element = (i - 1)
        break
      end
    end
    return dir, self_element
  else
    return Computar.new()
  end
end

---@paramter e Entry
---@return Directory?
function Directory:goto(e)
  if e.type == "directory" then
    return Directory.new(self.path .. "/" .. e.name, self)
  end
end

return Directory
