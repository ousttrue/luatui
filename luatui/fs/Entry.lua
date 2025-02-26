local icons_by_file_extension = require "luatui.nvim-web-devicons.default.icons_by_file_extension"

local ICON_MAP = {
  file = " ",
  directory = " ",
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
function Entry:get_icon()
  if self.type == "file" then
    local ext = self.name:match "[^%.]+$"
    local icon = icons_by_file_extension[ext]
    if icon then
      return icon.icon .. " "
    end
  elseif self.type == "directory" then
    if self.name == ".git" then
      return " "
    elseif self.name == ".vscode" then
      return " "
    elseif self.name == "node_modules" then
      return " "
    end
  elseif not ICON_MAP[self.type] then
    print(self.type)
  end

  return ICON_MAP[self.type]
end

---@return string
function Entry:__tostring()
  local str = self:get_icon() .. " " .. self.name
  return str
end

return Entry
