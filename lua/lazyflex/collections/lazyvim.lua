local M = {}

M.get_preset_keywords = function(name, enable_match)
  local presets = require("lazyflex.presets.lazyvim")
  local result = presets.presets[name]

  if result and enable_match then
    local extra = presets.when_enabling[name]
    if extra then
      result = vim.list_extend(vim.list_extend({}, result), extra)
    end
  end
  return result or {}
end

M.change_settings = function(settings)
  if not settings.options then
    package.loaded["lazyvim.config.options"] = true
    vim.g.mapleader, vim.g.maplocalleader = " ", "\\"
  end

  return {
    "LazyVim/LazyVim",
    opts = { defaults = { autocmds = settings.autocmds, keymaps = settings.keymaps } },
    optional = true,
  }
end

return M
