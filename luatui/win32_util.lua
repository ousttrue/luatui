--
-- win32
--

---@type uv
local uv = require "luv"

local bit = require "bit"
local ffi = require "ffi"

local kernel32 = ffi.load "kernel32"
ffi.cdef [[
typedef unsigned int UINT;
typedef long   BOOL;
typedef BOOL *   LPBOOL;
typedef unsigned short WORD;
typedef unsigned long DWORD;
typedef short SHORT;
typedef char *   LPSTR;
typedef const char * LPCSTR;
typedef short *   LPWSTR;
typedef const short * LPCWSTR;
typedef void* HANDLE;

HANDLE GetStdHandle(
  DWORD nStdHandle
);
BOOL GetConsoleMode(
  HANDLE  hConsoleHandle,
  DWORD* lpMode
);
BOOL SetConsoleMode(
  HANDLE hConsoleHandle,
  DWORD  dwMode
);
typedef struct _COORD {
  SHORT X;
  SHORT Y;
} COORD, *PCOORD;
typedef struct _SMALL_RECT {
  SHORT Left;
  SHORT Top;
  SHORT Right;
  SHORT Bottom;
} SMALL_RECT;
typedef struct _CONSOLE_SCREEN_BUFFER_INFO {
  COORD      dwSize;
  COORD      dwCursorPosition;
  WORD       wAttributes;
  SMALL_RECT srWindow;
  COORD      dwMaximumWindowSize;
} CONSOLE_SCREEN_BUFFER_INFO;
BOOL GetConsoleScreenBufferInfo(
  HANDLE                      hConsoleOutput,
  CONSOLE_SCREEN_BUFFER_INFO* lpConsoleScreenBufferInfo
);
]]

local M = {}
M.STD_INPUT_HANDLE = -10
M.STD_OUTPUT_HANDLE = -11
M.STD_ERROR_HANDLE = -12
M.ENABLE_VIRTUAL_TERMINAL_PROCESSING = 4

-- https://learn.microsoft.com/ja-jp/windows/console/console-virtual-terminal-sequences
function M.EnableVTMode()
  -- Set output mode to handle virtual terminal sequences
  local hOut = kernel32.GetStdHandle(M.STD_OUTPUT_HANDLE)
  if hOut == 0 then
    return false
  end

  local dwMode = ffi.new "DWORD[1]"
  if kernel32.GetConsoleMode(hOut, dwMode) == 0 then
    return false
  end

  dwMode[0] = bit.bor(dwMode[0], M.ENABLE_VIRTUAL_TERMINAL_PROCESSING)
  if kernel32.SetConsoleMode(hOut, dwMode[0]) == 0 then
    return false
  end

  return true
end

---@return integer? width
---@return integer? height
function M.get_winsize()
  local csbi = ffi.new "CONSOLE_SCREEN_BUFFER_INFO[1]"
  if kernel32.GetConsoleScreenBufferInfo(kernel32.GetStdHandle(M.STD_OUTPUT_HANDLE), csbi) ~= 0 then
    return csbi[0].srWindow.Right - csbi[0].srWindow.Left + 1, csbi[0].srWindow.Bottom - csbi[0].srWindow.Top + 1
  end
end

return M
