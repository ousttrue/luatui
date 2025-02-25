local utf8 = require "lua-utf8"
local wcwidth = require "wcwidth"

local M = {}

---@param src string
---@param dst_cols integer
---@pad pad string
function M.padding_right(src, dst_cols, pad)
  local src_cols = 0
  for i, cp in utf8.codes(src) do
    local cols = src_cols + wcwidth(cp)
    if cols == dst_cols then
      return src:sub(1, i)
    end
    src_cols = cols
  end
  if src_cols > dst_cols then
    assert(false, "not impl")
  elseif src_cols < dst_cols then
    for _ = src_cols, dst_cols - 1 do
      src = src .. pad
    end
    return src
  else
    return src
  end
end

return M
