local RenderTarget = require "luatui.RenderTarget"
local Cell = require "luatui.Cell"

describe("RenderTarget", function()
  it("new", function()
    do
      local rt = RenderTarget.new()
      rt:box(0, 0, 3, 3, " ")
      assert.are_same(Cell.new "╭", rt.rows[1].cells[1])
      assert.are_same(3, #rt.rows)
      local rows = {}
      for i, row in rt:render() do
        table.insert(rows, { i, row })
      end
      assert.are_same({ { 1, "╭─╮" }, { 2, "│ │" }, { 3, "╰─╯" } }, rows)
    end

    do
      local rt = RenderTarget.new()
      rt:box(0, 0, 4, 3, "に", {
        h = "─",
        v = "│",
        tl = "╭",
        tr = "╮",
        bl = "╰",
        br = "╯",
      })
      local rows = {}
      for i, row in rt:render() do
        table.insert(rows, row)
      end
      assert.are_same({ "╭──╮", "│に│", "╰──╯" }, rows)
    end
  end)
end)
