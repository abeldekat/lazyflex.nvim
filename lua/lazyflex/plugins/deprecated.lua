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

require("lazy.core.config").options.defaults.cond = function(plugin)
  local cond = function()
    local name = string.lower(plugin.name)
    for _, keyword in ipairs(opts.keywords) do
      if name:find(keyword, 1, true) then
        return opts.enable_on_match
      end
    end
    return not opts.enable_on_match
  end
  return cond()
end

return {
  {
    "LazyVim/LazyVim",
    opts = { defaults = { autocmds = opts.config.autocmds, keymaps = opts.config.keymaps } },
  },
}
