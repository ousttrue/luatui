---@class Entry
---@field name string
---@field type 'file'|'directory'|'link'
local Entry = {}
Entry.__index = Entry

return Entry
