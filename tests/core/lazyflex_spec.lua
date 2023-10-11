local assert = require("luassert")

local function test_spec()
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
local function test_spec_change(single_spec)
  local spec = test_spec()
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
local function fake_lazy(opts, fake_attach)
  return {
    get_opts = function()
      return opts
    end,
    get_object_to_attach = function()
      return fake_attach
    end,
  }
end

local function setup()
  local captures = {}
  local fake_attach = {
    add = function(_, plugin)
      table.insert(captures, plugin)
      return plugin
    end,
    captures = captures, -- extra property to use in tests
  }
  return fake_attach
end

local function activate(opts, fake_attach, spec)
  -- mimic lazy.nvim internals(adapter)
  local lazy = fake_lazy(opts, fake_attach)

  -- run lazyflex. See lazyflex.hook
  local return_spec = require("lazyflex").on_hook(lazy)

  -- simulate lazy.nvim parsing specs
  for _, plugin in ipairs(spec) do
    fake_attach.add(_, plugin)
  end
  return return_spec
end

-- captures contains all added plugins
-- the cond property of each captured plugin is filtered by the value of enable_match
local function filter_captured(captures, enable_match)
  local result = {}
  for _, plugin in ipairs(captures) do
    if plugin.cond == enable_match then
      table.insert(result, plugin.name)
    end
  end
  return result
end

local function plugin_captured(captures, name)
  local results = vim.tbl_filter(function(p)
    if p.name == name then
      return true
    end
    return false
  end, captures)
  return not vim.tbl_isempty(results) and results[1] or {}
end

-- test matching
describe("a match", function()
  it("is enabled by default", function()
    local fake_attach = setup()
    activate({ kw = { "cmp", "snip" } }, fake_attach, test_spec())

    local disabled = {
      "mini.comment",
      "nvim-lspconfig",
      "mason.nvim",
      "mason-lspconfig.nvim",
      "none-ls.nvim",
    }
    assert.same(disabled, filter_captured(fake_attach.captures, false))
  end)

  it("can also be disabled", function()
    local fake_attach = setup()
    activate({ enable_match = false, kw = { "snip" } }, fake_attach, test_spec())

    local expected = {
      "LuaSnip",
      "cmp-luasnip",
    }
    assert.same(expected, filter_captured(fake_attach.captures, false))
  end)

  it("can be based on presets", function()
    local fake_attach = setup()

    -- enable mini.comment and all plugins in lazyvim's lsp module
    local lazyvim = { presets = { "lsp", "dummy" } }
    activate({ lazyvim = lazyvim, kw = { "com" } }, fake_attach, test_spec())

    local disabled = {
      "LuaSnip",
      "nvim-cmp",
      "cmp-nvim-lsp",
      "cmp-luasnip",
      "cmp-buffer",
    }
    assert.same(disabled, filter_captured(fake_attach.captures, false))
  end)

  -- a disable plugin should not become conditionally disabled!
  it("is discarded when disabling and the plugin is unconditionally disabled", function()
    local fake_attach = setup()
    local spec = test_spec_change({ name = "mini.comment", enabled = false })

    -- disable, including mini.comment. However, mini.comment is already disabled!
    activate({ enable_match = false, kw = { "cmp", "snip", "comment" } }, fake_attach, spec)

    local disabled = {
      "LuaSnip",
      "nvim-cmp",
      "cmp-nvim-lsp",
      "cmp-luasnip",
      "cmp-buffer",
    }
    assert.same(disabled, filter_captured(fake_attach.captures, false))
    local mini_comment = plugin_captured(fake_attach.captures, "mini.comment")
    assert(mini_comment["cond"] == nil)
    assert(mini_comment["enabled"] == false)
  end)

  it("is discarded when enabling and the plugin is unconditionally disabled", function()
    local fake_attach = setup()
    local spec = test_spec_change({ name = "mini.comment", enabled = false })

    -- enable, including mini.comment. However, mini.comment is already disabled!
    activate({ kw = { "cmp", "snip", "comment" } }, fake_attach, spec)

    local disabled = {
      "nvim-lspconfig",
      "mason.nvim",
      "mason-lspconfig.nvim",
      "none-ls.nvim",
    }
    assert.same(disabled, filter_captured(fake_attach.captures, false))
    local mini_comment = plugin_captured(fake_attach.captures, "mini.comment")
    assert(mini_comment["cond"] == nil)
    assert(mini_comment["enabled"] == false)
  end)

  it("should repair cond=false when the plugin is unconditionally disabled", function()
    local fake_attach = setup()
    local spec = { { name = "mini.comment", cond = false, enabled = false } }

    -- disable mini.comment. However, mini.comment is already disabled!
    activate({ enable_match = false, kw = { "comment" } }, fake_attach, spec)

    local mini_comment = plugin_captured(fake_attach.captures, "mini.comment")
    assert(mini_comment["cond"] == true)
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

-- test opt-out early
describe("lazyflex", function()
  it("opts-out without keywords", function()
    local fake_attach = setup()
    local opts = { kw = {}, enable_match = true }
    activate(opts, fake_attach, test_spec())
    assert(#test_spec() == #filter_captured(fake_attach.captures, nil))
  end)
  it("opts-out without keywords or presets", function()
    local fake_attach = setup()
    local opts = { lazyvim = { presets = {} }, kw = {}, enable_match = true }
    activate(opts, fake_attach, test_spec())
    assert(#test_spec() == #filter_captured(fake_attach.captures, nil))
  end)
  it("opts-out without keywords or -valid- lazyvim presets", function()
    local fake_attach = setup()
    local opts = { lazyvim = { presets = { "dummy" } }, kw = {}, enable_match = true }
    activate(opts, fake_attach, test_spec())
    assert(#test_spec() == #filter_captured(fake_attach.captures, nil))
  end)
  it("opts-out without keywords or -valid- user presets", function()
    local fake_attach = setup()
    local opts = { user = { presets = { "dummy" } }, kw = {}, enable_match = true }
    activate(opts, fake_attach, test_spec())
    assert(#test_spec() == #filter_captured(fake_attach.captures, nil))
  end)
end)

-- test disabling settings
-- disabling options is tested in e2e_spec
describe("settings from LazyVim", function()
  it("are activated by default", function()
    local fake_attach = setup()
    local spec = test_spec()
    local return_spec = activate({ kw = { "LazyVim" } }, fake_attach, spec)

    -- only lazy.nvim and LazyVim enabled
    assert(#spec - 2 == #filter_captured(fake_attach.captures, false))
    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == true)
    assert(LazyVim.opts.defaults.keymaps == true)
  end)
  it("can be turned off", function()
    local fake_attach = setup()
    local spec = test_spec()
    local opts = { kw = { "LazyVim" }, lazyvim = { config = { enabled = false } } }
    local return_spec = activate(opts, fake_attach, spec)

    -- only lazy.nvim and LazyVim enabled
    assert(#spec - 2 == #filter_captured(fake_attach.captures, false))
    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == false)
    assert(LazyVim.opts.defaults.keymaps == false)
  end)
end)
