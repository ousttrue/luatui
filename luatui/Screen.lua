local win32_util = require "luatui.win32_util"
local Splitter = require "luatui.Splitter"
local RenderTarget = require "luatui.RenderTarget"

---@param uv uv
---@param output uv.uv_write_t
---@return integer width
---@return integer height
local function get_winsize(uv, output)
  if uv.guess_handle(assert(uv.fileno(output))) == "tty" then
    local w, h = uv.tty_get_winsize(output)
    if w and type(h) == "integer" then
      return w, h
    end
  end

  local w, h = win32_util.get_winsize()
  if w and h then
    return w, h
  end

  return 80, 24
end

---@param uv uv
---@param output uv.uv_write_t
---@param rt RenderTarget
local function flush(uv, output, rt, rows)
  for i = 0, rows - 1 do
    local line = rt:get_line(i)
    if line then
      uv.write(output, ("\x1b[%d;1H%s"):format(i + 1, line))
    end
  end
end

---@class Screen
---@field uv uv
---@field output uv.uv_write_t
---@field input uv.uv_stream_t
---@field root Splitter
---@field focus Splitter?
---@field on_end_frame fun()?
local Screen = {}
Screen.__index = Screen

---@param uv uv
---@param output uv.uv_write_t
---@return Screen
function Screen.new(uv, output, input)
  local width, height = get_winsize(uv, output)
  local self = setmetatable({
    uv = uv,
    output = output,
    input = input,
    root = Splitter.new(width, height),
  }, Screen)
  self:render()
  return self
end

---@return Screen
function Screen.make_tty_screen()
  local uv = require "luv"

  local g_tty_in
  if uv.guess_handle(0) == "tty" then
    g_tty_in = assert(uv.new_tty(0, true))
    -- raw mode
    uv.tty_set_mode(g_tty_in, 1)
  else
    g_tty_in = assert(uv.new_pipe(false))
    uv.pipe_open(g_tty_in, 0)
  end

  local stdout
  if uv.guess_handle(1) == "tty" then
    stdout = assert(uv.new_tty(1, false))
    -- raw mode
    -- assert(EnableVTMode())
  else
    stdout = assert(uv.new_pipe(false))
    uv.pipe_open(stdout, 1)
  end

  local s = Screen.new(uv, stdout, g_tty_in)
  return s
end

function Screen:run()
  self.uv.read_start(self.input, function(err, data)
    if err then
      self.uv.close(self.input)
    elseif data then
      local n = string.byte(data, 1, 1)
      if n == 3 or data == "q" then
        -- ctrl-c
        self.uv.read_stop(self.input)
      else
        self:process_input(data)

        if self.on_end_frame then
          self.on_end_frame()
        end
      end
    end
  end)

  self.uv.run()

  self.uv.tty_reset_mode()
end

---@param src string
function Screen:process_input(src)
  if self.focus and self.focus.callbacks then
    self.focus.callbacks.keymap(self.focus, {
      size = self.focus.current_size,
      data = src,
    })
  else
    self.root:process_input(src)
  end
end

function Screen:render(cursor_x, cursor_y)
  -- hide cursor
  self.uv.write(self.output, "\x1b[?25l")
  -- clear
  self.uv.write(self.output, "\x1b[1;1H")
  self.uv.write(self.output, "\x1b[2J")

  -- content
  local rt = RenderTarget.new()
  self.root:render(rt)
  flush(self.uv, self.output, rt, self.root.current_size.height)

  -- cursor
  if self.focus then
    self.uv.write(self.output, ("\x1b[%d;%dH"):format(cursor_y, cursor_x))
    -- show cursor
    self.uv.write(self.output, "\x1b[?25h")
  end
end

return Screen
