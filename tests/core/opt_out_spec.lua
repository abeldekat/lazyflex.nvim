local h = require("tests.unit_helpers")

-- a fixed spec to use in the tests
local function new_test_spec()
  local spec = {
    -- always enabled
    { name = "lazy.nvim" },
    { name = "LazyVim" },
    -- plugins from the lsp module in lazyvim
    { name = "nvim-lspconfig" },
    { name = "mason.nvim" },
    { name = "mason-lspconfig.nvim" },
  }
  return spec
end

-- test opt-out early
describe("lazyflex", function()
  it("opts-out without keywords", function()
    local spec = new_test_spec()
    local opts = { kw = {}, enable_match = true }
    h.activate(opts, spec)
    assert(#spec == #h.filter_not_modified(spec))
  end)

  it("opts-out without keywords or presets", function()
    local spec = new_test_spec()
    local opts = { lazyvim = { presets = {} }, kw = {}, enable_match = true }
    h.activate(opts, spec)
    assert(#spec == #h.filter_not_modified(spec))
  end)

  it("opts-out without keywords or -valid- lazyvim presets", function()
    local spec = new_test_spec()
    local opts = { lazyvim = { presets = { "dummy" } }, kw = {}, enable_match = true }
    h.activate(opts, spec)
    assert(#spec == #h.filter_not_modified(spec))
  end)

  it("opts-out without keywords or -valid- user presets", function()
    local spec = new_test_spec()
    local opts = { user = { presets = { "dummy" } }, kw = {}, enable_match = true }
    h.activate(opts, spec)
    assert(#spec == #h.filter_not_modified(spec))
  end)
end)
