--[[
This plugin should be the first plugin in the spec list!
The plugin operates in lazy's spec phase,
before lazy.nvim starts using the cond() function, disabling plugins.

example spec:

local use_flex = false -- switch to activate the plugin
local plugin_flex = not use_flex and {} or {
  "abeldekat/lazyflex.nvim",
  import = "lazyflex.plugins.intercept",
  opts = {
    keywords = { "pairs" }, -- only enable mini.pairs
  },
}

require("lazy").setup({
  plugin_flex,
  -- other plugins
})

lazyflex.plugins.deprecated:
overwrites the default cond function.
less powerful, plugins can define their own cond function...

lazyflex.plugins.intercept:
unconditionally overwrites the cond function of each plugin
--]]
local M = {}

M.setup = function(_)
  -- dummy function, invoked to late in the process..
end

return M
