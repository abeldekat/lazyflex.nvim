local assert = require("luassert")

local function fake_spec()
  return {
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
-- enable_match is the filter on the cond property
local function actual(captures, enable_match)
  local result = {}
  for _, plugin in ipairs(captures) do
    if plugin.cond == enable_match then
      table.insert(result, plugin.name)
    end
  end
  return result
end

-- test matching
describe("a match", function()
  it("is enabled by default", function()
    local fake_attach = setup()
    activate({ kw = { "cmp", "snip" } }, fake_attach, fake_spec())

    local disabled = {
      "mini.comment",
      "nvim-lspconfig",
      "mason.nvim",
      "mason-lspconfig.nvim",
      "none-ls.nvim",
    }
    assert.same(disabled, actual(fake_attach.captures, false))
  end)

  it("can also be disabled", function()
    local fake_attach = setup()
    activate({ enable_match = false, kw = { "snip" } }, fake_attach, fake_spec())

    local expected = {
      "LuaSnip",
      "cmp-luasnip",
    }
    assert.same(expected, actual(fake_attach.captures, false))
  end)

  it("can be based on presets", function()
    local fake_attach = setup()

    -- enable mini.comment and all plugins in lazyvim's lsp module
    local lazyvim = { presets = { "lsp", "dummy" } }
    activate({ lazyvim = lazyvim, kw = { "com" } }, fake_attach, fake_spec())

    local disabled = {
      "LuaSnip",
      "nvim-cmp",
      "cmp-nvim-lsp",
      "cmp-luasnip",
      "cmp-buffer",
    }
    assert.same(disabled, actual(fake_attach.captures, false))
  end)

  -- a disable plugin should not become conditionally disabled!
  -- it("does not add 'cond = false' when the plugin is 'enabled==false'", function()
  --   local results, target = setup()
  --   local specs = vim.tbl_map(function(spec)
  --     if spec.name == "mini.comment" then
  --       spec.enabled = false
  --     end
  --     return spec
  --   end, fake_spec())
  --
  --   activate({ kw = { "snip", "comment" } }, target, specs)
  --
  --   local expected = {
  --     "lazy.nvim",
  --     "LazyVim",
  --     "LuaSnip",
  --     "cmp-luasnip",
  --   }
  --   assert.same(expected, collect(results, true))
  -- end)
  --
  -- it("should also test the cond property as a function", function()
  --   assert(true)
  -- end)
  --
  -- it("should also test for enabled as a function", function()
  --   assert(true)
  -- end)
  --
  -- -- don't add a superfluous cond=true
  -- it("does not add 'cond = true' when the plugin is enabled", function()
  --   assert(true)
  -- end)
end)

-- test opt-out early
describe("lazyflex", function()
  it("opts-out without keywords", function()
    local fake_attach = setup()
    local opts = { kw = {}, enable_match = true }
    activate(opts, fake_attach, fake_spec())
    assert(#fake_spec() == #actual(fake_attach.captures, nil))
  end)
  it("opts-out without keywords or presets", function()
    local fake_attach = setup()
    local opts = { lazyvim = { presets = {} }, kw = {}, enable_match = true }
    activate(opts, fake_attach, fake_spec())
    assert(#fake_spec() == #actual(fake_attach.captures, nil))
  end)
  it("opts-out without keywords or -valid- lazyvim presets", function()
    local fake_attach = setup()
    local opts = { lazyvim = { presets = { "dummy" } }, kw = {}, enable_match = true }
    activate(opts, fake_attach, fake_spec())
    assert(#fake_spec() == #actual(fake_attach.captures, nil))
  end)
  it("opts-out without keywords or -valid- user presets", function()
    local fake_attach = setup()
    local opts = { user = { presets = { "dummy" } }, kw = {}, enable_match = true }
    activate(opts, fake_attach, fake_spec())
    assert(#fake_spec() == #actual(fake_attach.captures, nil))
  end)
end)

-- test disabling settings
-- disabling options is tested in e2e_spec
describe("settings from LazyVim", function()
  it("are activated by default", function()
    local fake_attach = setup()
    local spec = fake_spec()
    local return_spec = activate({ kw = { "LazyVim" } }, fake_attach, spec)
    assert(#spec - 2 == #actual(fake_attach.captures, false))

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == true)
    assert(LazyVim.opts.defaults.keymaps == true)
  end)
  it("can be turned off", function()
    local fake_attach = setup()
    local spec = fake_spec()
    local opts = { kw = { "LazyVim" }, lazyvim = { config = { enabled = false } } }
    local return_spec = activate(opts, fake_attach, spec)

    assert(#spec - 2 == #actual(fake_attach.captures, false))

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == false)
    assert(LazyVim.opts.defaults.keymaps == false)
  end)
end)
