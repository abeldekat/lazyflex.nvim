local assert = require("luassert")

-- see lazyflex.adapter.lazy:
-- closures on opts and target, accessible in the test
local function fake_adapter(opts, target)
  return {
    get_opts = function()
      return opts
    end,
    get_target = function()
      return target
    end,
    get_property_to_decorate = function()
      return "add"
    end,
  }
end

local function fake_spec()
  return {
    -- always enabled
    { name = "lazy.nvim" },
    { name = "LazyVim" },
    -- most of the plugins from the coding module in lazyvim
    { name = "LuaSnip" },
    { name = "nvim-cmp" },
    { name = "cmp-luasnip" },
    { name = "cmp-buffer" },
    { name = "mini.comment" },
    -- all plugins from the lsp module in lazyvim
    { name = "nvim-lspconfig" },
    { name = "cmp-nvim-lsp" },
    { name = "mason.nvim" },
    { name = "mason-lspconfig.nvim" },
    { name = "none-ls.nvim" },
  }
end

local function setup()
  local results = {}
  local target = {
    add = function(_, plugin)
      table.insert(results, plugin)
      return plugin
    end,
  }
  return results, target
end

local function activate(opts, target)
  local adapter = fake_adapter(opts, target) -- mimic lazy.nvim internals...
  local return_spec = require("lazyflex").on_hook(adapter) -- run the plugin, decorate target.add
  for _, plugin in ipairs(fake_spec()) do -- simulate lazy.nvim
    target.add(_, plugin)
  end
  return return_spec
end

local function collect(results, target_property, enable_match)
  local actual = {}
  for _, plugin in ipairs(results) do
    if plugin[target_property] == enable_match then
      table.insert(actual, plugin.name)
    end
  end
  return actual
end

-- test matching
describe("a match", function()
  it("is enabled by default", function()
    local results, target = setup()
    activate({ kw = { "cmp", "snip" } }, target)

    local expected = {
      "lazy.nvim",
      "LazyVim",
      "LuaSnip",
      "nvim-cmp",
      "cmp-luasnip",
      "cmp-buffer",
      "cmp-nvim-lsp",
    }
    assert.same(collect(results, "cond", true), expected)
  end)

  it("can also be disabled", function()
    local results, target = setup()
    activate({ enable_match = false, kw = { "snip" } }, target)

    local expected = {
      "LuaSnip",
      "cmp-luasnip",
    }
    assert.same(collect(results, "cond", false), expected)
  end)

  it("can target the enabled property", function()
    local results, target = setup()
    activate({ target_property = "enabled", kw = { "snip" } }, target)

    local expected = {
      "lazy.nvim",
      "LazyVim",
      "LuaSnip",
      "cmp-luasnip",
    }
    assert.same(collect(results, "enabled", true), expected)
  end)

  it("can be based on presets", function()
    local results, target = setup()

    -- enable mini.comment and all plugins in lazyvim's lsp and ui modules
    activate({ lazyvim = { presets = { "lsp", "ui" } }, kw = { "com" } }, target)

    local expected = {
      "lazy.nvim",
      "LazyVim",
      "mini.comment",
      "nvim-lspconfig",
      "cmp-nvim-lsp",
      "mason.nvim",
      "mason-lspconfig.nvim",
      "none-ls.nvim",
    }
    assert.same(collect(results, "cond", true), expected)
  end)
end)

-- test opt-out early
describe("lazyflex", function()
  it("opts-out without keywords", function()
    local results, target = setup()
    activate({ kw = {}, enable_match = true }, target)
    assert(#collect(results, "cond", nil) == #fake_spec())
  end)
  it("opts-out without keywords or presets", function()
    local results, target = setup()
    activate({ lazyvim = { presets = {} }, kw = {}, enable_match = true }, target)
    assert(#collect(results, "cond", nil) == #fake_spec())
  end)
  it("opts-out without keywords or -valid- lazyvim presets", function()
    local results, target = setup()
    activate({ lazyvim = { presets = { "dummy" } }, kw = {}, enable_match = true }, target)
    assert(#collect(results, "cond", nil) == #fake_spec())
  end)
  it("opts-out without keywords or -valid- user presets", function()
    local results, target = setup()
    activate({ user = { presets = { "dummy" } }, kw = {}, enable_match = true }, target)
    assert(#collect(results, "cond", nil) == #fake_spec())
  end)
end)

-- test disabling settings
-- disabling options is tested in e2e_spec
describe("settings from LazyVim", function()
  it("are activated by default", function()
    local results, target = setup()
    local return_spec = activate({ kw = { "LazyVim" } }, target)
    assert(#collect(results, "cond", true) == 2)

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == true)
    assert(LazyVim.opts.defaults.keymaps == true)
  end)
  it("can be turned off", function()
    local results, target = setup()
    local return_spec = activate({
      kw = { "LazyVim" },
      lazyvim = { config = { enabled = false } },
    }, target)

    assert(#collect(results, "cond", true) == 2)

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == false)
    assert(LazyVim.opts.defaults.keymaps == false)
  end)
end)
