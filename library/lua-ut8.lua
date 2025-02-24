---@meta lua-utf8

local utf8 = {}

function utf8.byte() end

---@param cp integer
---@return string
function utf8.char(cp) end

function utf8.find() end

function utf8.gmatch() end

function utf8.gsub() end

---@param string
---@return integer
function utf8.len(s) end

function utf8.lower() end

function utf8.match() end

function utf8.reverse() end

function utf8.sub() end

function utf8.upper() end

---@param s string
---@param n integer?
---@return integer
function utf8.offset(s, n) end

---@param s string
---@param i integer?
---@return integer
function utf8.codepoint(s, i) end

---@param s string
---@return fun(s: string, i: integer): integer?, integer
---@return s
---@return integer
function utf8.codes(s) end

---@param str string
---@return string utf8
function utf8.escape(str) end

return utf8
