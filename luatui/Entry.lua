local ICON_MAP = {
  file = " ",
  directory = " ",
  link = "󱞫 ",
}

---@class Entry
---@field name string
---@field type 'file'|'directory'|'link'
local Entry = {}
Entry.__index = Entry

---@param name string
---@param type string
---@return Entry
function Entry.new(name, type)
  local self = setmetatable({
    name = name,
    type = type,
  }, Entry)
  return self
end

---@param dir string
---@return Entry
function Entry.make_dir(dir)
  return Entry.new(dir, "directory")
end

---@return string
function Entry:__tostring()
  if not ICON_MAP[self.type] then
    print(self.type)
  end
  local str = ICON_MAP[self.type] .. " " .. self.name
  return str
end

return Entry
