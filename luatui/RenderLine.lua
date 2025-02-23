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
  -- while #self.cells <= (i + #str) do
  --   table.insert(self.cells, Cell.new())
  -- end
  for j = 1, i do
    self.cells[i] = Cell.new()
  end
  i = i + 1
  for _, cp in utf8.codes(str) do
    local cell = Cell.new(utf8.char(cp), sgr)
    for j = 1, cell:columns() do
      if j == 1 then
        self.cells[i] = cell
      else
        assert(false, "not impl")
      end
      i = i + 1
    end
  end
end

---@return string
function RenderLine:render()
  local str = ""
  for _, c in ipairs(self.cells) do
    str = str .. c:render()
  end
  return str
end

return RenderLine
