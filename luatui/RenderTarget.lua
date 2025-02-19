---@class RenderTarget
local RenderTarget = {}
RenderTarget.__index = RenderTarget

---@return RenderTarget
function RenderTarget.new()
  local self = setmetatable({}, RenderTarget)
  return self
end

---@param str string
---@param row integer
---@param col integer
function RenderTarget:write(row, col, str) end

---@param uv uv
---@param out uv.uv_write_t
function RenderTarget:flush(uv, out) end

return RenderTarget
