---@class RenderTarget
---@field rows table<integer, string>
local RenderTarget = {}
RenderTarget.__index = RenderTarget

---@return RenderTarget
function RenderTarget.new()
  local self = setmetatable({
    rows = {},
  }, RenderTarget)
  return self
end

local function fill(n)
  local s = ""
  for i = 1, n do
    s = s .. " "
  end
  return s
end

---@param str string
---@param row integer
---@param col integer
function RenderTarget:write(row, col, str)
  self.rows[row] = fill(col) .. str
end

---@param i integer
---@return string?
function RenderTarget:get_line(i)
  return self.rows[i]
end

return RenderTarget
