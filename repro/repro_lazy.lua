-- Minimal `init.lua` to reproduce an issue. Save as `repro.lua` and run with `nvim -u repro.lua`

-- sets std paths to use .repro and bootstraps lazy
-- DO NOT change the paths and don't remove the colorscheme
local function bootstrap(root)
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

-- optional: activate the flex plugin
local use_flex = false
local plugin_flex = not use_flex and {}
  or {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = { collection = false },
  }

-- install plugins
local plugins = {
  plugin_flex,
  "folke/tokyonight.nvim",
  -- add any other plugins here
}
require("lazy").setup(plugins, {
  root = root .. "/plugins",
})
vim.cmd.colorscheme("tokyonight")
-- add anything else here
