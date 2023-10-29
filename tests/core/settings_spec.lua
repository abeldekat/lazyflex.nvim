local h = require("tests.unit_helpers")

-- test disabling lazyvim's settings
-- disabling options is tested in e2e_spec
describe("settings from LazyVim", function()
  local function get_plugin()
    return {
      name = "LazyVim/LazyVim",
    }
  end
  it("are activated by default when providing opts.lazyvim", function()
    local plugin = get_plugin()
    local opts = { kw = { "LazyVim" }, lazyvim = {} }
    local return_spec = h.activate(opts, { plugin })

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == true)
    assert(LazyVim.opts.defaults.keymaps == true)
  end)

  it("can be turned off", function()
    local plugin = get_plugin()
    local opts = { kw = { "LazyVim" }, lazyvim = { settings = { enabled = false } } }
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
    }
  end
  it("are activated by default", function()
    local plugin = get_plugin()
    local user = {
      change_settings = function(config)
        local result = {
          "foo/bar",
          opts = config,
        }
        return result
      end,
    }
    local opts = { kw = { "com" }, user = user }
    local dummy_result = h.activate(opts, { plugin })

    local expected = {
      enabled = true,
      options = true,
      autocmds = true,
      keymaps = true,
    }

    assert.same(expected, dummy_result[1].opts)
  end)

  it("can be turned off ", function()
    local plugin = get_plugin()
    local user = {
      change_settings = function(config)
        local result = {
          "foo/bar",
          opts = config,
        }
        return result
      end,
      settings = { enabled = false },
    }
    local opts = { kw = { "com" }, user = user }
    local dummy_result = h.activate(opts, { plugin })

    local expected = {
      enabled = false,
      options = false,
      autocmds = false,
      keymaps = false,
    }

    assert.same(expected, dummy_result[1].opts)
  end)
end)
