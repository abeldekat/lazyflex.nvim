local h = require("tests.unit_helpers")

-- test disabling lazyvim's settings
-- disabling options is tested in e2e_spec
describe("settings from LazyVim", function()
  it("are discarded when opts.lazyvim is not provided", function()
    local opts = { kw = { "LazyVim" } }

    local return_spec = h.activate(opts, {})

    assert(vim.tbl_isempty(return_spec))
  end)

  it("are activated by default when providing opts.lazyvim", function()
    local opts = { kw = { "LazyVim" }, lazyvim = {} }

    local return_spec = h.activate(opts, {})

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == true)
    assert(LazyVim.opts.defaults.keymaps == true)
  end)

  it("can be turned off", function()
    local opts = { kw = { "LazyVim" }, lazyvim = { settings = { enabled = false } } }
    local return_spec = h.activate(opts, {})

    local LazyVim = return_spec[1]
    assert(LazyVim.opts.defaults.autocmds == false)
    assert(LazyVim.opts.defaults.keymaps == false)
  end)
end)

-- test disabling user settings
describe("settings from the user", function()
  it("are discarded when opts.user is not provided", function()
    local opts = { kw = { "bar" } }

    local return_spec = h.activate(opts, {})

    assert(vim.tbl_isempty(return_spec))
  end)

  it("are activated by default", function()
    local user = {
      change_settings = function(config)
        local result = {
          "foo/bar",
          opts = config,
        }
        return result
      end,
    }
    local opts = { kw = { "bar" }, user = user }
    local dummy_result = h.activate(opts, {})

    local expected = {
      enabled = true,
      options = true,
      autocmds = true,
      keymaps = true,
    }

    assert.same(expected, dummy_result[1].opts)
  end)

  it("can be turned off ", function()
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
    local opts = { kw = { "bar" }, user = user }
    local dummy_result = h.activate(opts, {})

    local expected = {
      enabled = false,
      options = false,
      autocmds = false,
      keymaps = false,
    }

    assert.same(expected, dummy_result[1].opts)
  end)
end)

it("are both processed correctly", function()
  describe("settings from lazyvim and the user", function()
    local function get_result(results, name)
      local name_of_first_result = results[1][1]
      return name_of_first_result == name and results[1] or results[2]
    end
    local lazyvim = { settings = { keymaps = false } }
    local user = {
      change_settings = function(settings)
        local result = {
          "foo/bar",
          opts = settings,
        }
        return result
      end,
      settings = { autocmds = false },
    }
    local opts = { kw = { "bar" }, lazyvim = lazyvim, user = user }
    local results = h.activate(opts, {})

    local expected_user = {
      enabled = true,
      options = true,
      autocmds = false,
      keymaps = true,
    }

    local lazyvim_result = get_result(results, "LazyVim/LazyVim")
    local user_result = get_result(results, "foo/bar")

    assert(lazyvim_result.opts.defaults.autocmds == true)
    assert(lazyvim_result.opts.defaults.keymaps == false)
    assert.same(expected_user, user_result.opts)
  end)
end)
