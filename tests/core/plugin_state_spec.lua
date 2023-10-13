--[[
-- NOTE:
-- all plugins are enabled in new_test_spec
-- thus, when using enable_match = true,
-- assertions must be done on plugins that are disabled...
--]]

local h = require("tests.unit_helpers")

-- a stripped down version of lazy.core.plugin#merge
local function merge(old, new)
  new._ = {}
  new._.super = old
  setmetatable(new, { __index = old })
  return new
end

-- test unconditionally disabled plugin
describe("an unconditionally disabled plugin", function()
  local function get_plugin()
    return { name = "mini.comment", enabled = false }
  end
  local function get_spec(plugin)
    return {
      { name = "LuaSnip" },
      { name = "cmp-luasnip" },
      plugin,
    }
  end
  -- a disable plugin should not become conditionally disabled!
  it("is discarded", function()
    local plugin = get_plugin()
    local spec = get_spec(plugin)

    -- disable, including mini.comment. However, mini.comment is already disabled!
    local opts = { enable_match = false, kw = { "snip", "comment" } }
    h.activate(opts, spec)

    assert.same({ "LuaSnip", "cmp-luasnip" }, h.filter_disabled(spec))
    assert(plugin["cond"] == nil) -- nothing changed
    assert(plugin["enabled"] == false)
  end)

  it("is repaired when cond=false", function()
    -- a disable plugin should not become conditionally disabled!
    local old = { name = "mini.comment" }
    local new = merge(old, get_plugin())

    -- disable mini.comment. However, mini.comment is already disabled!
    local opts = { enable_match = false, kw = { "comment" } }
    h.activate(opts, { old, new })

    assert(old["enabled"] == nil) -- first add: plugin is considered enabled
    assert(old["cond"] == false) -- thus, lazyflex add a conditional disabled
    assert(new["enabled"] == false) -- second add: the user disabled the plugin
    assert(new["cond"] == true) -- thus, lazyflex repairs cond
  end)
end)

-- test plugin NOT unconditionally disabled
describe("an enabled plugin", function()
  local function get_plugin()
    return {
      name = "mini.comment",
      cond = false,
      enabled = true,
    }
  end

  it("is enabled when cond=true", function()
    local plugin = get_plugin()

    h.activate({ kw = { "comment" } }, { plugin })

    assert(plugin["cond"] == true) -- no changes
    assert(plugin["enabled"] == true) -- no changes
  end)

  it("is also enabled when cond=false", function()
    local plugin = get_plugin()

    h.activate({ kw = { "comment" } }, { plugin })

    assert(plugin["cond"] == true) -- changed!
    assert(plugin["enabled"] == true) -- unchanged
  end)

  it("is also enabled when cond=false and enabled is not set", function()
    local plugin = get_plugin()
    plugin.enabled = nil

    h.activate({ kw = { "comment" } }, { plugin })

    assert(plugin["cond"] == true) -- changed!
    assert(plugin["enabled"] == nil) -- unchanged
  end)
end)

-- test optional plugin
describe("an optional plugin", function()
  -- when a plugin is removed from core,
  -- plugin.optional and plugin.enabled are used to inform the user

  local function get_plugin(module_name)
    return {
      name = "mini.comment",
      _ = { module = module_name },
      optional = true,
      enabled = true,
    }
  end

  it("is discarded when that plugin is in core", function()
    local plugin = get_plugin("lazyvim.plugins.coding")

    local opts = { enable_match = false, kw = { "comment" } }
    h.activate(opts, { plugin })

    assert(plugin["cond"] == nil)
  end)

  it("is processed when that plugin is in extras", function()
    local plugin = get_plugin("lazyvim.plugins.extras.mini")
    local spec = { plugin }

    local opts = { enable_match = false, kw = { "comment" } }
    h.activate(opts, spec)

    assert(plugin["cond"] == false)
  end)
end)
