if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end
local opts = require("lazyflex.config").setup()
local cond = require("lazyflex.utils").cond

-- same approach as in lazyvim.config.init():
local Plugin = require("lazy.core.plugin")
local original_add = Plugin.Spec.add

---@diagnostic disable-next-line: duplicate-set-field
Plugin.Spec.add = function(self, plugin, ...)
  local plugin_result = original_add(self, plugin, ...)
  if plugin_result then
    plugin_result.cond = cond(plugin_result.name, opts)
  end
  return plugin_result
end

local preset = require("lazyflex.presets").factory(opts.plugin_container)
preset.intercept_options(opts)
return preset.return_container_spec(opts)
