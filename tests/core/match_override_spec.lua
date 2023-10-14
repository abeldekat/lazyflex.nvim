local h = require("tests.unit_helpers")

-- a fixed spec to use in the tests
local function new_test_spec()
  local spec = {
    -- always enabled
    { name = "lazy.nvim" },
    { name = "LazyVim" },
    -- lazyvim coding
    { name = "LuaSnip" },
    { name = "nvim-cmp" },
    { name = "cmp-nvim-lsp" },
    { name = "cmp_luasnip" },
    { name = "cmp-buffer" },
    { name = "mini.comment" },
    -- lazyvim lsp
    { name = "nvim-lspconfig" },
  }
  return spec
end

-- test matching
describe("override_kw", function()
  local expect_disabled = {
    "LuaSnip",
    "cmp_luasnip",
    "mini.comment",
    "nvim-lspconfig",
  }
  it("overrides when kw is more generic than override_kw", function()
    local spec = new_test_spec()

    h.activate({ kw = { "cmp" }, override_kw = { "cmp_luasnip" } }, spec)

    assert.same(expect_disabled, h.filter_disabled(spec))
  end)

  it("overrides when kw is equal to override_kw", function()
    local spec = new_test_spec()

    h.activate({
      kw = { "nvim-cmp", "cmp-nvim-lsp", "cmp-luasnip", "cmp-buffer" },
      override_kw = { "cmp-luasnip" },
    }, spec)

    assert.same(expect_disabled, h.filter_disabled(spec))
  end)

  it("overrides when override_kw is more generic than kw", function()
    local spec = new_test_spec()

    h.activate({
      kw = { "nvim-cmp", "cmp-nvim-lsp", "cmp-luasnip", "cmp-buffer" },
      override_kw = { "cmp-luas" },
    }, spec)

    assert.same(expect_disabled, h.filter_disabled(spec))
  end)
end)
