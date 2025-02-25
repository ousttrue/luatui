local List = require "luatui.widgets.List"
local Viewport = require "luatui.Viewport"
local RenderTarget = require "luatui.RenderTarget"

describe("Widgets.List", function()
  it("list", function()
    local l = List.new { "a", "b", "c" }

    local rt = RenderTarget.new()
    l:render(rt, Viewport.from_size(3, 3))
    assert.are_same(3, #rt.rows)
    local rows = {}
    for i, row in rt:render() do
      table.insert(rows, row)
    end

    assert.are_same({
      "a",
      "b",
      "c",
    }, rows)
  end)
end)
