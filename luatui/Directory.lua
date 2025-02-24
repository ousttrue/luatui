---@type uv
local uv = require "luv"
local win32_util = require "luatui.win32_util"

---@class Directory
---@field dir string
---@field entries Entry[]
local Directory = {}
Directory.__index = Directory

---@param dir string
function Directory.new(dir)
  local real = uv.fs_realpath(dir)
  if real then
    dir = real
  end

  local self = setmetatable({
    dir = dir,
    entries = {},
  }, Directory)

  local fs = uv.fs_scandir(dir)
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
  return self.dir
end

---@return Directory|Computar
function Directory:get_parent()
  local basename = self.dir:match "[^/\\]+$"
  if basename then
    local dir = self.dir:sub(1, #self.dir - #basename)
    return Directory.new(dir)
  else
    return win32_util.Computar.new()
  end
end

---@paramter e Entry
---@return Directory?
function Directory:goto(e)
  if e.type == "directory" then
    return Directory.new(self.dir .. "/" .. e.name)
  end
end

return Directory
