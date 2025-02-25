local text_util = require "luatui.text_util"

describe("text_util", function()
  it("padding", function()
    assert.same("   ", text_util.padding_right("", 3, " "))
    assert.same("123", text_util.padding_right("1234", 3, " "))
  end)

  it("padding multibyte", function()
    assert.same("   ", text_util.padding_right("", 3, " "))
    assert.same("123", text_util.padding_right("1234", 3, " "))
  end)
end)
