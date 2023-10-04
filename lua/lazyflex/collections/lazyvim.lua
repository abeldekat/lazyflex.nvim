local M = {}

M.get_preset_keywords = function(name, enable_on_match)
  local presets = require("lazyflex.presets.lazyvim")
  local result = presets.presets[name]
  if not result then
    return {}
  end

  if enable_on_match then
    local extra = presets.when_enabling[name]
    if extra then
      result = vim.list_extend({}, result)
      result = vim.list_extend(result, extra)
    end
  end
  return result
end

M.return_spec = function(config)
  if not config.options then
    package.loaded["lazyvim.config.options"] = true
    vim.g.mapleader, vim.g.maplocalleader = " ", "\\"
  end

  return {
    "LazyVim/LazyVim",
    opts = { defaults = { autocmds = config.autocmds, keymaps = config.keymaps } },
    optional = true,
  }
end

return M
