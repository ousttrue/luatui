local Cell = require "luatui.Cell"

describe("Cell", function()
  it("ascii", function()
    do
      local cell = Cell.new()
      assert.are_same("", cell:render())
    end
  end)

  it("漢字", function()
    do
      local cell = Cell.new "漢"
      assert.are_same(2, cell:columns())
      assert.are_same(3, #cell.char)
      assert.are_same("漢", cell:render())
    end
  end)

  -- ╭─╮
  -- │ ││
  -- ╰─╯
  it("nerdfont", function()
    do
      local cell = Cell.new "╭"
      assert.are_same(1, cell:columns())
      assert.are_same(3, #cell.char)
      assert.are_same("╭", cell:render())
    end
  end)
end)
