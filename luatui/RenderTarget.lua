local RenderLine = require "luatui.RenderLine"

---@class RenderTarget
---@field rows table<integer, RenderLine>
local RenderTarget = {}
RenderTarget.__index = RenderTarget

---@return RenderTarget
function RenderTarget.new()
  local self = setmetatable({
    rows = {},
  }, RenderTarget)
  return self
end

---@param row integer
---@return RenderLine
function RenderTarget:get_or_create_line(row)
  local line = self.rows[row + 1]
  if not line then
    line = RenderLine.new()
    self.rows[row + 1] = line
  end
  return line
end

---@param str string
---@param row integer
---@param col integer
---@param sgr SGR?
function RenderTarget:write(row, col, str, sgr)
  local line = self:get_or_create_line(row)
  line:write(col, str, sgr)
end

-- ╭─╮
-- │ │
-- ╰─╯
function RenderTarget:box(x, y, w, h, str)
  do
    local line = self:get_or_create_line(y)
    line:write(x, "+")
    for col = x, x + w - 2 do
      line:write(col, "-")
    end
    line:write(x + w - 1, "+")
  end

  for row = y, y + h - 2 do
    local line = self:get_or_create_line(row)
    line:write(x, "|")
    line:write(x + w - 1, "|")
  end

  do
    local line = self:get_or_create_line(y + h - 1)
    line:write(x, "+")
    for col = x, x + w - 2 do
      line:write(col, "-")
    end
    line:write(x + w - 1, "+")
  end

  do
    local line = self:get_or_create_line(y + math.floor(h / 2))
    line:write(x + math.floor((w - #str) / 2), str)
  end
end

---@param i integer
---@return string? line
function RenderTarget:get_line(i)
  local line = self.rows[i]
  if line then
    return line:render()
  end
end

return RenderTarget
