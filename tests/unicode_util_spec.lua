local utf8 = require "lua-utf8"
local wcwidth = require "wcwidth"

describe("unicode_util", function()
  it("iter", function()
    do
      local str = "aあ漢"
      assert.same(3, utf8.len(str))
      assert.same(1, utf8.offset(str, 1))
      assert.same(2, utf8.offset(str, 2))
      assert.same(5, utf8.offset(str, 3))
      assert.same(8, utf8.offset(str, 4))
      assert.same(97, utf8.codepoint(str, 1))
      assert.same(0x3042, utf8.codepoint(str, 2))
      assert.same(0x6F22, utf8.codepoint(str, 5))
      local i_cp = {}
      for i, cp in utf8.codes(str) do
        table.insert(i_cp, { i, cp, wcwidth(cp) })
      end
      assert.same({
        { 1, 97, 1 },
        { 2, 0x3042, 2 },
        { 5, 0x6F22, 2 },
      }, i_cp)
    end
  end)
end)
