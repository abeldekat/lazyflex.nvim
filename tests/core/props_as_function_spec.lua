local h = require("tests.unit_helpers")
-- test properties cond and enabled as a function
describe("spec properties", function()
  local function get_plugin()
    return {
      name = "mini.comment",
      cond = false,
      enabled = false,
    }
  end

  it("can be a function, ie. cond", function()
    local plugin = get_plugin()
    plugin.cond = function()
      return false
    end
    local opts = { enable_match = false, kw = { "com" } }

    h.activate(opts, { plugin })

    assert(plugin["enabled"] == false)
    assert(plugin["cond"] == true) -- repaired, cond as function is recognized
  end)

  it("can be a function, ie. enabled", function()
    local plugin = get_plugin()
    plugin.enabled = function()
      return false
    end
    local opts = { enable_match = false, kw = { "com" } }

    h.activate(opts, { plugin })

    assert(plugin["enabled"]() == false)
    assert(plugin["cond"] == true) -- repaired, enabled as function is recognized
  end)
end)
