local assert = require("luassert")

local function get_dir()
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h:h")
end

describe("lazyflex.nvim", function()
  before_each(function()
    vim.g.lazy_did_setup = false
    vim.go.loadplugins = true
    for modname in pairs(package.loaded) do
      if modname:find("lazy") == 1 then
        package.loaded[modname] = nil
      end
    end
  end)

  it("integrates with lazy.nvim", function()
    local Lazy = require("lazy")
    local Config = require("lazy.core.config")

    Lazy.setup({
      {
        "abeldekat/lazyflex.nvim",
        dir = get_dir(),
        import = "lazyflex.hook",
        opts = { keywords = { "paint" } },
      },
      "folke/neodev.nvim",
      "folke/paint.nvim",
    }, { install_missing = true })

    assert(3 == vim.tbl_count(Config.plugins))

    local disabled = Config.spec.disabled["neodev.nvim"]
    assert.is_table(disabled)
    assert.is_false(disabled._.cond)
  end)
end)
