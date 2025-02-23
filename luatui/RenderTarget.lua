---@type utf8
local utf8 = require "lua-utf8"

---@class Cell
---@field char string? a character. maybe full width. if perv column is full width, next column is nil.
---@field sgr integer?
local Cell = {}
Cell.__index = Cell

---@param char string?
---@pram str integer?
---@return Cell
function Cell.new(char, sgr)
  local self = setmetatable({
    char = char,
    sgr = sgr,
  }, Cell)
  return self
end

---@param str string
---@param i integer
---@return Cell
function Cell.from_str(str, i, sgr)
  local self = setmetatable({
    char = str:sub(i, i),
    sgr = sgr,
  }, Cell)
  return self
end

---@return string?
function Cell:render()
  if self.char then
    if self.sgr then
      -- print(self.sgr)
      return ("\x1b[%dm%s"):format(self.sgr, self.char)
    else
      return self.char
    end
  end
end

---@class RenderLine
---@field cells Cell[]
local RenderLine = {}
RenderLine.__index = RenderLine

---@return RenderLine
function RenderLine.new()
  local self = setmetatable({
    cells = {},
  }, RenderLine)
  return self
end

---@param col integer
---@param str string
---@param sgr SGR?
function RenderLine:write(col, str, sgr)
  while #self.cells <= (col + #str) do
    table.insert(self.cells, Cell.new())
  end
  local i = col + 1
  for _, cp in utf8.codes(str) do
    local cell = Cell.new(utf8.char(cp), sgr)
    self.cells[i] = cell
    i = i + 1
  end
end

---@return string
function RenderLine:render()
  local str = ""
  for _, c in ipairs(self.cells) do
    assert(c)
    if c.char then
      str = str .. c:render()
    end
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
