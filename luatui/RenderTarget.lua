---@class RenderLine
---@field cells string[]
local RenderLine = {}
RenderLine.__index = RenderLine

---@return RenderLine
function RenderLine.new()
  local self = setmetatable({
    cells = {},
  }, RenderLine)
  return self
end

function RenderLine:write(col, str)
  while #self.cells < (col + #str) do
    table.insert(self.cells, " ")
  end
  for i = 1, #str do
    self.cells[col + i] = str:sub(i, i)
  end
end

---@return string
function RenderLine:render()
  local str = ""
  for _, c in ipairs(self.cells) do
    str = str .. c
  end
  return str
end

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
  local line = self.rows[row]
  if not line then
    line = RenderLine.new()
    self.rows[row] = line
  end
  return line
end

---@param str string
---@param row integer
---@param col integer
function RenderTarget:write(row, col, str)
  local line = self:get_or_create_line(row)
  line:write(col, str)
end

-- ╭─╮
-- │ │
-- ╰─╯
function RenderTarget:box(x, y, w, h, str)
  do
    local line = self:get_or_create_line(y)
    line:write(x, "+")
    for col = x + 1, x + w - 2 do
      line:write(col, "-")
    end
    line:write(x + w - 1, "+")
  end

  for row = y + 1, y + h - 2 do
    local line = self:get_or_create_line(row)
    line:write(x, "|")
    line:write(x + w - 1, "|")
  end

  do
    local line = self:get_or_create_line(y + h - 1)
    line:write(x, "+")
    for col = x + 1, x + w - 2 do
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
