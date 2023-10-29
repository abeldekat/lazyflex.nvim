--[[
Provides a central place in the code where lazy.nvim is used

inversion of control pattern
important benefit: testing...
- Making sure the integration works -> see e2e_spec.lua
- Making sure lazyflex works -> see unit test specs
--]]
local M = {}

-- Returns the opts the user configured for lazyflex.nvim
function M.get_opts()
  local lazyflex_plugin = require("lazy.core.config").spec.plugins["lazyflex.nvim"]
  local opts = lazyflex_plugin.opts or {}

  if type(opts) == "function" then
    return opts(lazyflex_plugin, {})
  end
  return opts
end

function M.add(lazyflex_add)
  local Spec = require("lazy.core.plugin").Spec
  local add = Spec.add

  ---@diagnostic disable-next-line: duplicate-set-field
  Spec.add = function(_, plugin)
    add(_, plugin)
    lazyflex_add(_, plugin)
    return plugin
  end

  -- detach when done
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = function()
      Spec.add = add
    end,
  })
end

function M.import(lazyflex_import)
  local Spec = require("lazy.core.plugin").Spec
  local imp = Spec.import

  ---@diagnostic disable-next-line: duplicate-set-field
  Spec.import = function(_, spec)
    if lazyflex_import(_, spec) then
      imp(_, spec)
    end
  end

  -- detach when done
  -- also needed for the LazyExtra command...
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = function()
      Spec.import = imp
    end,
  })
end

return M
