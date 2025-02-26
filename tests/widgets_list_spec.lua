local List = require "luatui.widgets.List"
local Viewport = require "luatui.Viewport"
local RenderTarget = require "luatui.RenderTarget"

describe("Widgets.List", function()
  it("fit", function()
    local l = List.new { "a", "b", "c" }

    local rt = RenderTarget.new()
    l:render(rt, Viewport.from_size(3, 3))
    assert.are_same(3, #rt.rows)
    local rows = {}
    for _, row in rt:render() do
      table.insert(rows, row)
    end

    assert.are_same({
      "a  ",
      "b  ",
      "c  ",
    }, rows)
  end)

  it("long", function()
    local l = List.new { "a", "b", "c" }

    local rt = RenderTarget.new()
    l:render(rt, Viewport.from_size(3, 4))
    assert.are_same(4, #rt.rows)
    local rows = {}
    for _, row in rt:render() do
      table.insert(rows, row)
    end

    assert.are_same({
      "a  ",
      "b  ",
      "c  ",
      "   ",
    }, rows)
  end)

  it("short", function()
    local l = List.new { "a", "b", "c", "d" }

    local rt = RenderTarget.new()
    local vp = Viewport.from_size(3, 3)
    l:render(rt, vp)
    assert.are_same(3, #rt.rows)
    local rows = {}
    for _, row in rt:render() do
      table.insert(rows, row)
    end

    assert.Truthy(l:is_visible(vp, 0))
    assert.Truthy(l:is_visible(vp, 1))
    assert.False(l:is_visible(vp, 2))

    assert.are_same({
      "a ▒",
      "b ▒",
      "c ░",
    }, rows)
  end)

  it("short", function()
    local l = List.new({ "a", "b", "c", "d" }, { scroll = 1 })

    local rt = RenderTarget.new()
    local vp = Viewport.from_size(3, 3)
    l:render(rt, vp)
    assert.are_same(3, #rt.rows)
    local rows = {}
    for _, row in rt:render() do
      table.insert(rows, row)
    end

    assert.Falsy(l:is_visible(vp, 0))
    assert.Truthy(l:is_visible(vp, 1))
    assert.Truthy(l:is_visible(vp, 2))

    assert.are_same({
      "b ░",
      "c ▒",
      "d ▒",
    }, rows)
  end)
end)
