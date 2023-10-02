if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end
local opts = require("lazyflex.config").setup()
local cond = require("lazyflex.core").cond

-- same approach as in lazyvim.config.init.init():
local Plugin = require("lazy.core.plugin")
local original_add = Plugin.Spec.add

---@diagnostic disable-next-line: duplicate-set-field
Plugin.Spec.add = function(self, plugin, ...)
  local plugin_result = original_add(self, plugin, ...)

  local name = plugin_result and plugin_result.name or nil
  if not (plugin_result and name) then
    return plugin_result
  end
  plugin_result.cond = cond(name, opts)
  return plugin_result
end

local preset = require("lazyflex.presets").factory(opts.plugin_container)
preset.intercept_options(opts)
return preset.return_container_spec(opts)
