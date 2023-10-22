local h = require("tests.unit_helpers")

-- test import
describe("lazyflex import", function()
  it("is disabled by default and does not do anything regarding imports", function()
    local spec = { { "test/baz" }, { import = "foo" }, { import = "bar" } }
    local opts = { kw = { "baz" } }

    h.activate(opts, spec)

    assert(spec[2].is_imported == nil) -- untouched
    assert(spec[3].is_imported == nil) -- untouched
  end)

  it("always imports lazyvim.plugins and plugins", function()
    local spec = { { import = "lazyvim.plugins" }, { import = "plugins" } }
    local opts = { filter_import = { enabled = true } }

    h.activate(opts, spec)

    assert(spec[1].is_imported == true)
    assert(spec[2].is_imported == true)
  end)

  it("imports nothing else when filter_import.kw is empty", function()
    local spec = { { import = "foo" }, { import = "bar" }, { import = "baz" } }
    local opts = { filter_import = { enabled = true, kw = {} } }
    h.activate(opts, spec)

    assert(spec[1].is_imported == false)
    assert(spec[2].is_imported == false)
    assert(spec[3].is_imported == false)
  end)

  it("filters correctly", function()
    local spec = { { import = "foo" }, { import = "bar" }, { import = "baz" } }
    local opts = { filter_import = { enabled = true, kw = { "f", "az" } } }
    h.activate(opts, spec)

    assert(spec[1].is_imported == true)
    assert(spec[2].is_imported == false)
    assert(spec[3].is_imported == true)
  end)
end)
