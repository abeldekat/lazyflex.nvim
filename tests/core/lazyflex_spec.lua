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

local function filter_disabled(spec)
  return filter_actual(spec, false)
end

local function filter_not_modified(spec)
  return filter_actual(spec, nil)
end

-- test matching
describe("a match", function()
  it("uses enable_match=true by default", function()
    local spec = new_test_spec()

    activate({ kw = { "cmp", "snip" } }, spec)

    -- stylua: ignore start
    assert.same({
      "mini.comment", "nvim-lspconfig", "mason.nvim", "mason-lspconfig.nvim",
    }, filter_disabled(spec))
    -- stylua: ignore end
  end)

  it("can also handle enable_match=false", function()
    local spec = new_test_spec()
    activate({ enable_match = false, kw = { "snip" } }, spec)

    assert.same({
      "LuaSnip",
      "cmp-luasnip",
    }, filter_disabled(spec))
  end)

  it("can use presets", function()
    local spec = new_test_spec()

    -- enable mini.comment and all plugins in lazyvim's lsp module
    local opts = { lazyvim = { presets = { "lsp", "dummy" } }, kw = { "com" } }
    activate(opts, spec)

    -- stylua: ignore start
    assert.same({
      "LuaSnip", "nvim-cmp", "cmp-nvim-lsp", "cmp-luasnip", "cmp-buffer",
    }, filter_disabled(spec))
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
    assert(#spec == #filter_not_modified(spec))
  end)

  it("opts-out without keywords or -valid- lazyvim presets", function()
    local spec = new_test_spec()
    local opts = { lazyvim = { presets = { "dummy" } }, kw = {}, enable_match = true }
    activate(opts, spec)
    assert(#spec == #filter_not_modified(spec))
  end)

  it("opts-out without keywords or -valid- user presets", function()
    local spec = new_test_spec()
    local opts = { user = { presets = { "dummy" } }, kw = {}, enable_match = true }
    activate(opts, spec)
    assert(#spec == #filter_not_modified(spec))
  end)
end)

describe("an unconditionally disabled plugin", function()
  -- a disable plugin should not become conditionally disabled!
  it("is discarded", function()
    local mini_comment = { name = "mini.comment", enabled = false }
    local spec = new_test_spec_change(mini_comment)

    -- disable, including mini.comment. However, mini.comment is already disabled!
    activate({ enable_match = false, kw = { "cmp", "snip", "comment" } }, spec)

    -- stylua: ignore start
    assert.same({
      "LuaSnip", "nvim-cmp", "cmp-nvim-lsp", "cmp-luasnip", "cmp-buffer",
    }, filter_actual(spec, false))
    -- stylua: ignore end
    assert(mini_comment["cond"] == nil) -- nothing changed
    assert(mini_comment["enabled"] == false)
  end)

  it("is repaired when cond=false", function()
    -- a disable plugin should not become conditionally disabled!
    local function merge(old, new)
      new._ = {}
      new._.super = old
      setmetatable(new, { __index = old })
      return new
    end
    local old = { name = "mini.comment" }
    local new = merge(old, { name = "mini.comment", enabled = false })
    local spec = { old, new }

    -- disable mini.comment. However, mini.comment is already disabled!
    activate({ enable_match = false, kw = { "comment" } }, spec)

    assert(old["enabled"] == nil) -- first add: plugin is considered enabled
    assert(old["cond"] == false) -- thus, lazyflex add a conditional disabled
    assert(new["enabled"] == false) -- second add: the user disabled the plugin
    assert(new["cond"] == true) -- thus, lazyflex repairs cond
  end)
end)

describe("spec properties", function()
  it("can be a function, ie. cond", function()
    local plugin = {
      name = "mini.comment",
      cond = function()
        return false
      end,
      enabled = false,
    }
    local spec = { plugin }
    local opts = { enable_match = false, kw = { "com" } }

    activate(opts, spec)

    assert(plugin["enabled"] == false)
    assert(plugin["cond"] == true) -- repaired, cond as function is recognized
  end)

  it("can be a function, ie. enabled", function()
    local plugin = {
      name = "mini.comment",
      cond = false,
      enabled = function()
        return false
      end,
    }
    local spec = { plugin }
    local opts = { enable_match = false, kw = { "com" } }

    activate(opts, spec)

    assert(plugin["enabled"]() == false)
    assert(plugin["cond"] == true) -- repaired, enabled as function is recognized
  end)
end)

-- test disabling settings
-- disabling options is tested in e2e_spec
describe("settings from LazyVim", function()
  it("are activated by default", function()
    local spec = new_test_spec()
    local return_spec = activate({ kw = { "LazyVim" } }, spec)

    -- only lazy.nvim and LazyVim enabled
    assert(#spec - 2 == #filter_disabled(spec))
    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == true)
    assert(LazyVim.opts.defaults.keymaps == true)
  end)

  it("can be turned off", function()
    local spec = new_test_spec()
    local opts = { kw = { "LazyVim" }, lazyvim = { config = { enabled = false } } }
    local return_spec = activate(opts, spec)

    -- only lazy.nvim and LazyVim enabled
    assert(#spec - 2 == #filter_disabled(spec))
    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == false)
    assert(LazyVim.opts.defaults.keymaps == false)
  end)
end)
