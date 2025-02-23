-- https://en.wikipedia.org/wiki/ANSI_escape_code#SGR
---@enum SGR Select Graphic Rendition
local SGR = {
  reset = 0, --All attributes become turned off
  bold_on = 1,
  bold_off = 22,
  underline_on = 4,
  underline_off = 24,
  invert_on = 7,
  invert_off = 27,
}

return SGR
