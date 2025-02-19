local wcwidth, utf8 = require "wcwidth", require "lua-utf8"
assert(utf8)

local function display_width(s)
  local len = 0
  for _, rune in utf8.codes(s) do
    local l = wcwidth(rune)
    if l >= 0 then
      len = len + l
    end
  end
  return len
end

local function alignright(s, cols)
  local numspaces = cols - display_width(s)
  local spaces = ""
  while numspaces > 0 do
    numspaces = numspaces - 1
    spaces = spaces .. " "
  end
  return spaces .. s
end

print(alignright("コンニチハ", 80))
