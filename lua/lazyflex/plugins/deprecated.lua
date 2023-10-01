--[[
deprecated, but keep for now
use intercept.lua
--]]
if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end

local opts = require("lazyflex.config").setup()

if not opts.config.options then
  package.loaded["lazyvim.config.options"] = true
  vim.g.mapleader, vim.g.maplocalleader = " ", "\\"
end

local cond = require("lazyflex.utils").cond
require("lazy.core.config").options.defaults.cond = function(plugin)
  return cond(plugin.name, opts)
end

return {
  {
    "LazyVim/LazyVim",
    opts = { defaults = { autocmds = opts.config.autocmds, keymaps = opts.config.keymaps } },
  },
}
