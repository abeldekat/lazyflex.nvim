if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end

local opts = require("lazyflex.config").setup()

if not opts.config.options then
  package.loaded["lazyvim.config.options"] = true
  vim.g.mapleader, vim.g.maplocalleader = " ", "\\"
end

local function add_cond(name)
  for _, keyword in ipairs(opts.keywords) do
    if name:find(keyword, 1, true) then
      return opts.enable_on_match
    end
  end
  return not opts.enable_on_match
end

-- same approach as in lazyvim.config.init()
local Plugin = require("lazy.core.plugin")
local add = Plugin.Spec.add
Plugin.Spec.add = function(self, plugin, ...)
  local plugin_result = add(self, plugin, ...)

  if plugin_result then
    local cond = add_cond(string.lower(plugin_result.name))
    plugin_result.cond = cond
  end
  return plugin_result
end

return {
  {
    "LazyVim/LazyVim",
    opts = { defaults = { autocmds = opts.config.autocmds, keymaps = opts.config.keymaps } },
  },
}
