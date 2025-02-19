local Screen = require "luatui.Screen"

---@class Cursor
---@field cursor_x integer
---@field cursor_y integer
local Cursor = {}
Cursor.__index = Cursor

---@return Cursor
function Cursor.new()
  local self = setmetatable({
    cursor_x = 0,
    cursor_y = 0,
  }, Cursor)
  return self
end

function Cursor:input(input)
  local consumed = false
  if input.data == "h" then
    self.cursor_x = self.cursor_x - 1
    consumed = true
  elseif input.data == "j" then
    self.cursor_y = self.cursor_y + 1
    consumed = true
  elseif input.data == "k" then
    self.cursor_y = self.cursor_y - 1
    consumed = true
  elseif input.data == "l" then
    self.cursor_x = self.cursor_x + 1
    consumed = true
  else
  end
  -- clamp
  if self.cursor_x < 0 then
    self.cursor_x = 0
  elseif self.cursor_x >= input.size.width then
    self.cursor_x = input.size.width - 1
  end
  if self.cursor_y < 0 then
    self.cursor_y = 0
  elseif self.cursor_y >= input.size.height then
    self.cursor_y = input.size.height - 1
  end
  return consumed
end

function Cursor:label(viewport)
  return ("xy (%d:%d)/(%d:%d)"):format(self.cursor_x, self.cursor_y, viewport.width, viewport.height)
end

local s = Screen.make_tty_screen()
local left, right = s.root:split_vertical()
s.focus = right

local function tab_function(input)
  if input.data == "\t" then
    s.focus = (s.focus == right) and left or right
    return true
  end
end

local function make_callbacks(c)
  return {
    keymap = function(splitter, input)
      if c:input(input) then
        return true
      end
      if tab_function(input) then
        return true
      end
      return false
    end,
    render = function(rt, viewport)
      rt:write(viewport.y, viewport.x, c:label(viewport))
    end,
  }
end

local left_cursor = Cursor.new()
left.callbacks = make_callbacks(left_cursor)
local right_cursor = Cursor.new()
right.callbacks = make_callbacks(right_cursor)

s.on_end_frame = function()
  local x, y = s.root:get_offset(s.focus)

  local c = s.focus == right and right_cursor or left_cursor
  s:render(c.cursor_x + x + 1, c.cursor_y + y + 1)
end

-- ╭─── Live Grep ╮
-- │> round       │
-- ╰──────────────╯

s:run()
