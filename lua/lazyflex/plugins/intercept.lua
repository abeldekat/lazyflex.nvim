if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end

local opts = require("lazyflex.config").setup()

if not opts.config.options then
  package.loaded["lazyvim.config.options"] = true
  vim.g.mapleader, vim.g.maplocalleader = " ", "\\"
end

-- same approach as in lazyvim.config.init()
local Plugin = require("lazy.core.plugin")
local original_add = Plugin.Spec.add
local cond = require("lazyflex.utils").cond

---@diagnostic disable-next-line: duplicate-set-field
Plugin.Spec.add = function(self, plugin, ...)
  local plugin_result = original_add(self, plugin, ...)
  if plugin_result then
    plugin_result.cond = cond(plugin_result.name, opts)
  end
  return plugin_result
end

return {
  {
    "LazyVim/LazyVim",
    opts = { defaults = { autocmds = opts.config.autocmds, keymaps = opts.config.keymaps } },
  },
}
