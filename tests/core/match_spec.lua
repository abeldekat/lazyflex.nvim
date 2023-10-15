--[[
-- NOTE:
-- all plugins are enabled in new_test_spec
-- thus, when using enable_match = true,
-- assertions must be done on plugins that are disabled...
--]]
local h = require("tests.unit_helpers")

-- a fixed spec to use in the tests
local function new_test_spec()
  local spec = {
    -- always enabled
    { name = "lazy.nvim" },
    { name = "LazyVim" },
    -- most of the plugins from the coding module in lazyvim
    { name = "LuaSnip" },
    { name = "nvim-cmp" },
    { name = "cmp-nvim-lsp" },
    { name = "cmp_luasnip" },
    { name = "cmp-buffer" },
    { name = "mini.comment" },
    -- all plugins from the lsp module in lazyvim
    { name = "nvim-lspconfig" },
    { name = "mason.nvim" },
    { name = "mason-lspconfig.nvim" },
  }
  return spec
end

-- test matching
describe("the matching process", function()
  it("uses enable_match=true by default", function()
    local spec = new_test_spec()

    h.activate({ kw = { "cmp", "snip" } }, spec)

    -- stylua: ignore start
    assert.same({ -- 
      "mini.comment", "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim",
    }, h.filter_disabled(spec))
    -- stylua: ignore end
  end)

  it("always enables all plugins with lazy in the name when enable_match=true", function()
    local spec = new_test_spec()

    -- overwrite kw_always_enable: when enabling, always enable mini.comment
    local opts = { kw_always_enable = { "comment" }, kw = { "cmp", "snip" } }
    h.activate(opts, spec)

    -- stylua: ignore start
    assert.same({ 
      "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim",
    }, h.filter_disabled(spec))
    -- stylua: ignore end
  end)

  it("ignores kw_always_enable when enable_match=false", function()
    local spec = new_test_spec()

    -- disables lazy!
    local opts = { enable_match = false, kw_always_enable = { "comment" }, kw = { "lazy" } }
    h.activate(opts, spec)

    assert.same({ "lazy.nvim", "LazyVim" }, h.filter_disabled(spec))
  end)

  it("can also handle enable_match=false", function()
    local spec = new_test_spec()

    h.activate({ enable_match = false, kw = { "snip" } }, spec)

    assert.same({
      "LuaSnip",
      "cmp_luasnip",
    }, h.filter_disabled(spec))
  end)

  it("can use presets", function()
    local spec = new_test_spec()

    -- enable mini.comment and all plugins in lazyvim's lsp module
    local opts = { lazyvim = { presets = { "lsp", "dummy" } }, kw = { "com" } }
    h.activate(opts, spec)

    -- stylua: ignore start
    assert.same({
      "LuaSnip", "nvim-cmp", "cmp-nvim-lsp", "cmp_luasnip", "cmp-buffer",
    }, h.filter_disabled(spec))
    -- stylua: ignore end
  end)
end)
