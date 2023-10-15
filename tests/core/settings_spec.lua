local h = require("tests.unit_helpers")

-- test disabling lazyvim's settings
-- disabling options is tested in e2e_spec
describe("settings from LazyVim", function()
  local function get_plugin()
    return {
      name = "LazyVim/LazyVim",
      enabled = false,
    }
  end
  it("are activated by default", function()
    local plugin = get_plugin()
    local opts = { kw = { "LazyVim" } }
    local return_spec = h.activate(opts, { plugin })

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == true)
    assert(LazyVim.opts.defaults.keymaps == true)
  end)

  it("can be turned off", function()
    local plugin = get_plugin()
    local opts = { kw = { "LazyVim" }, lazyvim = { config = { enabled = false } } }
    local return_spec = h.activate(opts, { plugin })

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == false)
    assert(LazyVim.opts.defaults.keymaps == false)
  end)
end)

-- test disabling user settings
describe("settings from the user", function()
  local function get_plugin()
    return {
      name = "mini.comment",
      enabled = false,
    }
  end
  it("are activated by default", function()
    local plugin = get_plugin()
    local opts = { kw = { "com" }, user = { mod = "tests.dummy_collection" } }
    local dummy_result = h.activate(opts, { plugin }, { "user" })

    local expected = {
      enabled = true,
      options = true,
      autocmds = true,
      keymaps = true,
    }

    assert.same(expected, dummy_result[1].opts)
  end)

  it("can be turned off using a custom module", function()
    local plugin = get_plugin()
    local user = { mod = "tests.dummy_collection", config = { enabled = false } }
    local opts = { kw = { "com" }, user = user }
    local dummy_result = h.activate(opts, { plugin }, { "user" })

    local expected = {
      enabled = false,
      options = false,
      autocmds = false,
      keymaps = false,
    }

    assert.same(expected, dummy_result[1].opts)
  end)

  it("can be turned off using a function", function()
    local plugin = get_plugin()
    local user = {
      return_spec = function(config)
        local result = {
          "foo/bar",
          opts = config,
        }
        return result
      end,
      config = { enabled = false },
    }
    local opts = { kw = { "com" }, user = user }
    local dummy_result = h.activate(opts, { plugin }, { "user" })

    local expected = {
      enabled = false,
      options = false,
      autocmds = false,
      keymaps = false,
    }

    assert.same(expected, dummy_result[1].opts)
  end)
end)
