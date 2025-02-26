local icons_by_file_extension = require "luatui.nvim-web-devicons.default.icons_by_file_extension"
---@type uv
local uv = require "luv"
local Text = require "luatui.widgets.Text"

local ICON_MAP = {
  file = " ",
  directory = " ",
  link = "󱞫 ",
}

---@class EntryOpts
---@field path string?
---@field content string?

---@class Entry
---@field name string
---@field type 'file'|'directory'|'link'
---@field opts EntryOpts
local Entry = {}
Entry.__index = Entry

---@param name string
---@param type string
---@param opts EntryOpts?
---@return Entry
function Entry.new(name, type, opts)
  opts = opts or {}
  local self = setmetatable({
    name = name,
    type = type,
    opts = opts,
  }, Entry)
  return self
end

---@param dir string
---@return Entry
function Entry.make_dir(dir)
  return Entry.new(dir, "directory")
end

---@param type string
---@param dir string
---@param name string
---@return Entry
function Entry.from_dir_name(type, dir, name)
  local path = uv.fs_realpath(dir .. "/" .. name)
  return Entry.new(name, type, { path = path })
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

---@return string?
function Entry:get_content()
  if not self.opts.content then
    if self.opts.path then
      local stat = uv.fs_stat(self.opts.path)
      if stat then
        local fd = uv.fs_open(self.opts.path, "r", 0)
        if fd then
          local content = uv.fs_read(fd, stat.size)
          if content then
            self.opts.content = content
          end
        end
      end
    end
  end
  return self.opts.content
end

local TEXT_EXT = {
  md = true,
  gltf = true,
  json = true,
  yaml = true,
  yml = true,
  toml = true,
}

---@param rt RenderTarget
---@param viewport Viewport
function Entry:render_preview(rt, viewport)
  if self.type == "file" then
    local ext = self.name:match "[^%.]+$"
    if TEXT_EXT[ext] then
      local content = self:get_content()
      if content then
        local text = Text.new(content)
        text:render(rt, viewport)
      end
    end
  else
    -- git project
    rt:write(viewport.y, viewport.x, tostring(self))
  end
end

return Entry
