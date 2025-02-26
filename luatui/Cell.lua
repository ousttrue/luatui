local wcwidth = require "wcwidth"
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
    sgr = sgr or 0,
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

---@return 0|1|2
function Cell:columns()
  local n = 0
  for _, cp in utf8.codes(self.char) do
    n = n + wcwidth(cp)
  end
  return n
end

---@param last_sgr SGR?
---@return string?
---@return SGR?
function Cell:render(last_sgr)
  last_sgr = last_sgr or 0
  if self.char and #self.char > 0 then
    if self.sgr ~= last_sgr then
      -- print(self.sgr)
      return ("\x1b[%dm%s"):format(self.sgr, self.char), self.sgr
    else
      return self.char, self.sgr
    end
  end
end

return Cell
