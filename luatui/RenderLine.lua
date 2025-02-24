local utf8 = require "lua-utf8"

local Cell = require "luatui.Cell"
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

---@param i integer
---@param str string
---@param sgr SGR?
function RenderLine:write(i, str, sgr)
  local col = i + 1
  for j = 1, col do
    if not self.cells[j] then
      self.cells[j] = Cell.new " "
    end
  end

  for _, cp in utf8.codes(str) do
    local cell = Cell.new(utf8.char(cp), sgr)
    for j = 1, cell:columns() do
      if j == 1 then
        self.cells[col] = cell
      else
        self.cells[col] = Cell.new(nil)
      end
      col = col + 1
    end
  end
end

---@return string
function RenderLine:render()
  local str = ""
  local sgr = nil
  for _, c in ipairs(self.cells) do
    str = str .. c:render(sgr)
    sgr = c.sgr
  end
  return str
end

return RenderLine
