local text_util = require "luatui.text_util"

---@class Text
---@field lines string[]
local Text = {}
Text.__index = Text

---@return Text
function Text.new(content)
  local self = setmetatable({
    lines = {},
  }, Text)
  local pos = 1
  while pos <= #content do
    local found = string.find(content, "\n", pos)
    if not found then
      break
    end
    table.insert(self.lines, content:sub(pos, found - 1))
    pos = found + 1
  end
  return self
end

---@param rt RenderTarget
---@param viewport Viewport
function Text:render(rt, viewport)
  local i = 1
  for y = viewport.y, viewport.y + viewport.height - 1 do
    local line = self.lines[i]
    if line then
      rt:write(y, viewport.x, text_util.padding_right(line, viewport.width, " "))
    else
      rt:write(y, viewport.x, text_util.padding_right("", viewport.width, " "))
    end
    i = i + 1
  end
end

return Text
