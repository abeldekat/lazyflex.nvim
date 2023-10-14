local h = require("tests.unit_helpers")

-- a fixed spec to use in the tests
local function new_test_spec()
  local spec = {
    -- always enabled
    { name = "lazy.nvim" },
    { name = "LazyVim" },
    -- coding module in lazyvim
    { name = "LuaSnip" },
    { name = "nvim-cmp" },
    { name = "cmp-nvim-lsp" },
    { name = "cmp_luasnip" },
    { name = "cmp-buffer" },
    { name = "mini.comment" },
    -- lsp module in lazyvim
    { name = "nvim-lspconfig" },
    { name = "mason.nvim" },
    { name = "mason-lspconfig.nvim" },
  }
  return spec
end

-- test matching
describe("kw_invert testing", function()
  it("does work when the kw is broader than kw_invert", function()
    local spec = new_test_spec()

    h.activate({ kw = { "cmp" }, kw_invert = { "cmp_luasnip" } }, spec)

    -- stylua: ignore
    assert.same({
      "LuaSnip","cmp_luasnip", "mini.comment", "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim",
    }, h.filter_disabled(spec))
  end)

  it("works when the kw is equal to kw_invert", function()
    local spec = new_test_spec()

    h.activate({
      kw = { "nvim-cmp", "cmp-nvim-lsp", "cmp-luasnip", "cmp-buffer" },
      kw_invert = { "cmp-luasnip" },
    }, spec)

    -- stylua: ignore
    assert.same({
      "LuaSnip","cmp_luasnip", "mini.comment", "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim",
    }, h.filter_disabled(spec))
  end)

  it("works when kw_invert is broader than kw", function()
    local spec = new_test_spec()

    h.activate({
      kw = { "nvim-cmp", "cmp-nvim-lsp", "cmp-luasnip", "cmp-buffer" },
      kw_invert = { "cmp-luas" },
    }, spec)

    -- stylua: ignore
    assert.same({
      "LuaSnip","cmp_luasnip", "mini.comment", "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim",
    }, h.filter_disabled(spec))
  end)
end)
