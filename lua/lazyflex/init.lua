--[[
This plugin should be the first plugin in the spec list!
The plugin operates in lazy's spec phase,
before lazy.nvim starts using the cond() function, disabling plugins.

example spec:

local use_flex = false -- switch to activate the plugin
local spec_flex = not use_flex and {} or {
  "abeldekat/lazyflex.nvim",
  import = "lazyflex.plugins.default_cond",
  -- import = "lazyflex.plugins.plugin_cond",
  opts = {
    keywords = { "pairs" }, -- only enable mini.pairs
  },
}

require("lazy").setup({
  spec_flex,
  -- other plugins
})

lazyflex.plugins.spec_default_cond
overwrites the default cond function.
slightly less powerful, when plugins have their own cond function defined...

lazyflex.plugins.spec_plugin_cond
unconditionally overwrites the cond function of each plugin
--]]
local M = {}

M.setup = function(_)
  -- dummy function, invoked to late in the process..
end

return M
