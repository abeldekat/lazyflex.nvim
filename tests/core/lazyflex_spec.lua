local assert = require("luassert")

local function new_test_spec()
  local spec = {
    -- always enabled
    { name = "lazy.nvim" },
    { name = "LazyVim" },
    -- most of the plugins from the coding module in lazyvim
    { name = "LuaSnip" },
    { name = "nvim-cmp" },
    { name = "cmp-nvim-lsp" },
    { name = "cmp-luasnip" },
    { name = "cmp-buffer" },
    { name = "mini.comment" },
    -- all plugins from the lsp module in lazyvim
    { name = "nvim-lspconfig" },
    { name = "mason.nvim" },
    { name = "mason-lspconfig.nvim" },
    { name = "none-ls.nvim" },
  }
  return spec
end

-- returns test_spec and changes one single item
local function new_test_spec_change(single_spec)
  local spec = new_test_spec()
  if single_spec then
    spec = vim.tbl_map(function(s)
      if s.name == single_spec.name then
        return single_spec
      end
      return s
    end, spec)
  end
  return spec
end

-- see lazyflex.adapter.lazy: simulate the interaction with lazy.nvim
local function fake_lazy(opts, to_attach)
  return {
    get_opts = function()
      return opts
    end,
    get_object_to_attach = function()
      return to_attach
    end,
  }
end

local function activate(opts, spec)
  -- simulate lazy.nvim internals(adapter)
  local lazy_attached = {
    add = function(_, plugin)
      -- lazy.nvim adds and returns the plugin...
      return plugin
    end,
  }
  local lazy = fake_lazy(opts, lazy_attached)

  -- run lazyflex. See lazyflex.hook. Decorates lazy_attached.add
  local return_spec = require("lazyflex").on_hook(lazy)

  -- lazy.nvim parses the spec
  for _, plugin in ipairs(spec) do
    lazy_attached.add(_, plugin)
  end
  return return_spec
end

-- filters the spec using plugin.cond==enable_match
local function filter_actual(spec, enable_match)
  local result = {}
  for _, plugin in ipairs(spec) do
    if plugin.cond == enable_match then
      table.insert(result, plugin.name)
    end
  end
  return result
end

local function plugin_actual(spec, name)
  local results = vim.tbl_filter(function(p)
    if p.name == name then
      return true
    end
    return false
  end, spec)
  return not vim.tbl_isempty(results) and results[1] or {}
end

-- test matching
describe("a match", function()
  it("uses enable_target by default", function()
    local spec = new_test_spec()

    activate({ kw = { "cmp", "snip" } }, spec)

    -- stylua: ignore start
    assert.same({
      "mini.comment", "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim", "none-ls.nvim",
    }, filter_actual(spec, false))
    -- stylua: ignore end
  end)

  it("can also handle enable_match=false", function()
    local spec = new_test_spec()
    activate({ enable_match = false, kw = { "snip" } }, spec)

    assert.same({
      "LuaSnip",
      "cmp-luasnip",
    }, filter_actual(spec, false))
  end)

  it("can use presets", function()
    local spec = new_test_spec()

    -- enable mini.comment and all plugins in lazyvim's lsp module
    local opts = { lazyvim = { presets = { "lsp", "dummy" } }, kw = { "com" } }
    activate(opts, spec)

    -- stylua: ignore start
    assert.same({
      "LuaSnip", "nvim-cmp", "cmp-nvim-lsp", "cmp-luasnip", "cmp-buffer",
    }, filter_actual(spec, false))
    -- stylua: ignore end
  end)
end)

-- test opt-out early
describe("lazyflex", function()
  it("opts-out without keywords", function()
    local spec = new_test_spec()
    local opts = { kw = {}, enable_match = true }
    activate(opts, spec)
    assert(#spec == #filter_actual(spec, nil))
  end)

  it("opts-out without keywords or presets", function()
    local spec = new_test_spec()
    local opts = { lazyvim = { presets = {} }, kw = {}, enable_match = true }
    activate(opts, spec)
    assert(#spec == #filter_actual(spec, nil))
  end)

  it("opts-out without keywords or -valid- lazyvim presets", function()
    local spec = new_test_spec()
    local opts = { lazyvim = { presets = { "dummy" } }, kw = {}, enable_match = true }
    activate(opts, spec)
    assert(#spec == #filter_actual(spec, nil))
  end)

  it("opts-out without keywords or -valid- user presets", function()
    local spec = new_test_spec()
    local opts = { user = { presets = { "dummy" } }, kw = {}, enable_match = true }
    activate(opts, spec)
    assert(#spec == #filter_actual(spec, nil))
  end)
end)

describe("an unconditionally disabled plugin", function()
  -- a disable plugin should not become conditionally disabled!
  it("is discarded when disabling", function()
    local spec = new_test_spec_change({ name = "mini.comment", enabled = false })

    -- disable, including mini.comment. However, mini.comment is already disabled!
    activate({ enable_match = false, kw = { "cmp", "snip", "comment" } }, spec)

    -- stylua: ignore start
    assert.same({
      "LuaSnip", "nvim-cmp", "cmp-nvim-lsp", "cmp-luasnip", "cmp-buffer",
    }, filter_actual(spec, false))
    -- stylua: ignore end
    local mini_comment = plugin_actual(spec, "mini.comment")
    assert(mini_comment["cond"] == nil)
    assert(mini_comment["enabled"] == false)
  end)

  it("should be repaired when disabling and cond=false", function()
    local spec = { { name = "mini.comment", cond = false, enabled = false } }
    -- TODO: Object!

    -- disable mini.comment. However, mini.comment is already disabled!
    activate({ enable_match = false, kw = { "comment" } }, spec)

    local mini_comment = plugin_actual(spec, "mini.comment")
    assert(mini_comment["cond"] == true) -- repaired!
    assert(mini_comment["enabled"] == false)
  end)

  it("is discarded when enabling", function()
    local spec = new_test_spec_change({ name = "mini.comment", enabled = false })

    -- enable, including mini.comment. However, mini.comment is already disabled!
    activate({ kw = { "cmp", "snip", "comment" } }, spec)

    -- stylua: ignore start
    assert.same({
      "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim", "none-ls.nvim",
    }, filter_actual(spec, false))
    -- stylua: ignore end
    local mini_comment = plugin_actual(spec, "mini.comment")
    assert(mini_comment["cond"] == nil)
    assert(mini_comment["enabled"] == false)
  end)

  -- it("should also test the cond property as a function", function()
  --   assert(true)
  -- end)
  --
  -- it("should also test for enabled as a function", function()
  --   assert(true)
  -- end)
  --
end)

-- test disabling settings
-- disabling options is tested in e2e_spec
describe("settings from LazyVim", function()
  it("are activated by default", function()
    local spec = new_test_spec()
    local return_spec = activate({ kw = { "LazyVim" } }, spec)

    -- only lazy.nvim and LazyVim enabled
    assert(#spec - 2 == #filter_actual(spec, false))
    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == true)
    assert(LazyVim.opts.defaults.keymaps == true)
  end)

  it("can be turned off", function()
    local spec = new_test_spec()
    local opts = { kw = { "LazyVim" }, lazyvim = { config = { enabled = false } } }
    local return_spec = activate(opts, spec)

    -- only lazy.nvim and LazyVim enabled
    assert(#spec - 2 == #filter_actual(spec, false))
    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == false)
    assert(LazyVim.opts.defaults.keymaps == false)
  end)
end)
