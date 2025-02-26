local utf8 = require "lua-utf8"
local wcwidth = require "wcwidth"

local M = {}

---@param src string
---@param dst_cols integer
---@pad pad string
function M.padding_right(src, dst_cols, pad)
  local dst = ""
  local cols = 0
  for _, cp in utf8.codes(src) do
    local w = wcwidth(cp)
    local next_cols = cols + w
    if next_cols > dst_cols then
      break
    end

    dst = dst .. utf8.char(cp)
    if next_cols == dst_cols then
      return dst
    end
    cols = next_cols
  end

  for _ = cols, dst_cols - 1 do
    dst = dst .. pad
  end
  return dst
end

return M
