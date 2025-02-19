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
    self.cells[col + i + 1] = str:sub(i, i)
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

---@param str string
---@param row integer
---@param col integer
function RenderTarget:write(row, col, str)
  local line = self.rows[row]
  if not line then
    line = RenderLine.new()
    self.rows[row] = line
  end
  line:write(col, str)
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
