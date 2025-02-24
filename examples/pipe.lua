local uv = require "luv"
local utf8 = require "lua-utf8"

local function spawn(path, args, input, output)
  local options = {
    stdio = { input, output },
    args = args,
  }
  uv.spawn(path, options, function(code, signal)
    assert(code == 0, "Failed to spawn " .. path)
    uv.close(output)
  end)
end

local function read_pipe(callback)
  local pipe = uv.new_pipe(false)

  local cmd = [[Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -match "^\w$"} | ForEach-Object{ $_.Name }]]
  spawn("pwsh", { "-NoProfile", "-c", cmd }, 0, pipe)
  -- spawn("awk", { [[{ print NR ": " $0; }]] }, pipe1, pipe2)

  local res = ""
  uv.read_start(pipe, function(err, chunk)
    if not chunk then
      uv.read_stop(pipe)
      callback(res)
      return
    end
    res = res .. chunk
  end)
end

read_pipe(function(res)
  for i, cp in utf8.codes(res) do
    print(i, cp)
  end
  -- print(res)
end)

uv.run()
