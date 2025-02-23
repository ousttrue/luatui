local RenderLine = require "luatui.RenderLine"

describe("RenderLine", function()
  it("new", function()
    do
      local line = RenderLine.new()
      line:write(0, "hello")
      assert.are_same(5, #line.cells)
      assert.are_same("hello", line:render())
    end

    do
      local line = RenderLine.new()
      line:write(1, "hello")
      assert.are_same(" hello", line:render())
    end

    do
      local line = RenderLine.new()
      line:write(1, "に")
      assert.are_same(" に", line:render())
    end
  end)
end)
