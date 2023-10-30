---@diagnostic disable:assign-type-mismatch
local function clone(owner, name)
  local url = string.format("%s/%s/%s.git", "https://github.com", owner, name)
  local path = vim.fn.stdpath("data") .. "/lazy/" .. name
  if not vim.loop.fs_stat(path) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", url, "--branch=stable", path })
  end
  return path
end

local lazypath = clone("folke", "lazy.nvim")
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local plugins = {
  { "abeldekat/lazyflex.nvim", version = "*", import = "lazyflex.hook", opts = {} },
  -- add LazyVim and import its plugins
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  -- import/override with your plugins
  { import = "plugins" },
}

require("lazy").setup({
  spec = plugins,
  defaults = { lazy = false, version = false }, -- "*" = latest stable version
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true },
  performance = { -- disable some rtp plugins. Add lazyflex to the rtp
    rtp = { -- "matchit", "matchparen",
      disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
      paths = { clone("abeldekat", "lazyflex.nvim") },
    },
  },
})
