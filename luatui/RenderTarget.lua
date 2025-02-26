local RenderLine = require "luatui.RenderLine"
local utf8 = require "lua-utf8"
local wcwidth = require "wcwidth"
local SGR = require "luatui.SGR"

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

---@param y integer
---@return RenderLine
function RenderTarget:get_or_create_line(y)
  local row = y + 1
  local line = self.rows[row]
  if not line then
    line = RenderLine.new()
    self.rows[row] = line
  end
  return line
end

---@param str string
---@param y integer
---@param x integer
---@param sgr SGR?
function RenderTarget:write(y, x, str, sgr)
  local line = self:get_or_create_line(y)
  line:write(x, str, sgr)
end

---@param x integer
---@param top integer
---@param height integer
---@param opts RenderOpts?
function RenderTarget:vertical_line(x, top, height, opts)
  opts = opts or {}
  opts.v = opts.v or "|"
  for y = top, top + height - 1 do
    local line = self:get_or_create_line(y)
    line:write(x, opts.v, SGR.reset)
  end
end

-- local BOX_OPTS = {
--   h = "-",
--   v = "|",
--   tl = "+",
--   tr = "+",
--   bl = "+",
--   br = "+",
-- }

local BOX_OPTS = {
  h = "─",
  v = "│",
  tl = "╭",
  tr = "╮",
  bl = "╰",
  br = "╯",
}

-- ╭─╮
-- │ │
-- ╰─╯
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param str string?
---@param box_opts {h: string, v: string, tl:string, tr:string, bl:string, br:string}?
function RenderTarget:box(x, y, w, h, str, box_opts)
  box_opts = box_opts or BOX_OPTS

  do
    -- top
    local line = self:get_or_create_line(y)
    line:write(x, box_opts.tl)
    for col = x + 1, x + w - 2 do
      line:write(col, box_opts.h)
    end
    line:write(x + w - 1, box_opts.tr)
  end

  for row = y + 1, y + h - 2 do
    local line = self:get_or_create_line(row)
    line:write(x, box_opts.v)
    line:write(x + w - 1, box_opts.v)
  end

  do
    -- bottom
    local line = self:get_or_create_line(y + h - 1)
    line:write(x, box_opts.bl)
    for col = x + 1, x + w - 2 do
      line:write(col, box_opts.h)
    end
    line:write(x + w - 1, box_opts.br)
  end

  if str then
    local line = self:get_or_create_line(y + math.floor(h / 2))
    local cols = 0
    for _, cp in utf8.codes(str) do
      local wc = wcwidth(cp)
      if cols + wc > w - 2 then
        break
      end
      line:write(cols + x + 1, utf8.char(cp))
      cols = cols + wc
    end
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

---@return fun(rows:RenderLine[], i:integer):integer, string
---@return RenderLine[]
---@return integer row
function RenderTarget:render()
  local function iter(rows, _i)
    local i = _i + 1
    local row = rows[i]
    if row then
      return i, row:render()
    end
  end
  return iter, self.rows, 0
end

return RenderTarget
