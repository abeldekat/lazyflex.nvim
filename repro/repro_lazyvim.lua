-- Minimal `init.lua` to reproduce an issue. Save as `repro.lua` and run with `nvim -u repro.lua`

-- sets std paths to use .repro and bootstraps lazy
local function bootstrap(root) -- DO NOT change the paths
  for _, name in ipairs({ "config", "data", "state", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
  end
  local lazypath = root .. "/plugins/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
  end
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
end
local root = vim.fn.fnamemodify("./.repro", ":p")
bootstrap(root)

-- install plugins
local plugins = {
  -- optional: reduce the number of plugins needed to reproduce the problem
  { "abeldekat/lazyflex.nvim", enabled = false, version = "*", import = "lazyflex.entry.lazyvim", opts = {} },

  "folke/tokyonight.nvim",
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  -- add any other plugins here
}
require("lazy").setup(plugins, {
  root = root .. "/plugins",
})
-- add anything else here
