---@type uv
local uv = require "luv"
local Entry = require "luatui.fs.Entry"

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
  assert(pipe)

  local cmd = [[Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Name -match "^\w$"} | ForEach-Object{ $_.Name }]]
  spawn("pwsh", { "-NoProfile", "-c", cmd }, 0, pipe)

  ---@type Entry[]
  local entries = {}
  uv.read_start(pipe, function(err, chunk)
    if not chunk then
      uv.read_stop(pipe)
      callback(entries)
      return
    end
    local drive = chunk:match "^(%w)%s*$"
    if drive then
      table.insert(entries, Entry.make_dir(drive .. ":\\"))
    else
      assert(false, "[" .. chunk .. "]")
    end
  end)
end

---@class Computar
---@field entries Entry[]
local Computar = {}
Computar.__index = Computar

---@return Computar
function Computar.new()
  local self = setmetatable({
    entries = {},
  }, Computar)

  read_pipe(function(entries)
    for _, e in ipairs(entries) do
      table.insert(self.entries, e)
    end
  end)

  return self
end

function Computar:__tostring()
  return "computar"
end

function Computar:get_parent() end

---@param e Entry
---@return Directory
function Computar:goto(e)
  local Directory = require "luatui.fs.Directory"
  return Directory.new(e.name, self)
end

return Computar
