local RenderTarget = require "luatui.RenderTarget"
local Splitter = require "luatui.Splitter"
local Viewport = require "luatui.Viewport"

describe("Layout", function()
  it("split_horizontal", function()
    local s = Splitter.new()
    s:split_horizontal()
    local rt = RenderTarget.new()
    s:render(rt, Viewport.from_size(3, 3))
    assert.same(3, #rt.rows)

    local rows = {}
    for i, row in rt:render() do
      table.insert(rows, { i, row })
    end
    assert.are_same({
      { 1, "   " },
      { 2, "---" },
      { 3, "   " },
    }, rows)
  end)

  it("split_vertical", function()
    local s = Splitter.new()
    s:split_vertical()
    assert.same(2, #s.children)
    local rt = RenderTarget.new()
    s:render(rt, Viewport.from_size(3, 3))
    assert.same(3, #rt.rows)

    local rows = {}
    for i, row in rt:render() do
      table.insert(rows, { i, row })
    end
    assert.are_same({
      { 1, " | " },
      { 2, " | " },
      { 3, " | " },
    }, rows)
  end)
end)
