---@class Entry
---@field name string
---@field type 'file'|'directory'|'link'
local Entry = {}
Entry.__index = Entry

---@param dir string
---@return Entry
function Entry.make_dir(dir)
  local self = setmetatable {
    name = dir,
    type = "directory",
  }
  return self
end

return Entry
