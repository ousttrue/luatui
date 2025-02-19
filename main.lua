print(package.path)

---@type uv
local uv = require "luv"
local Screen = require "luatui.Screen"

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

local s = Screen.new(uv, stdout)

uv.read_start(g_tty_in, function(err, data)
  if err then
    uv.close(g_tty_in)
  elseif data then
    local n = string.byte(data, 1, 1)
    if n == 3 or data == "q" then
      -- ctrl-c
      uv.read_stop(g_tty_in)
    else
      s:input(data)
    end
  end
end)

--
-- SIGWINCH
--
--   uv_signal_init(uv_default_loop(), &g_signal_resize);
--   g_signal_resize.data = &r;
--   uv_signal_start(
--       &g_signal_resize,
--       [](uv_signal_t *handle, int signum) {
--         ((Renderer *)handle->data)->onResize();
--       },
--       SIGWINCH);

uv.run()

uv.tty_reset_mode()
