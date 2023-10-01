local M = {}

local presets = {
  coding = {
    "LuaSnip", -- TODO: no snippets when only this preset enabled?
    "friendly-snippets",
    "nvim-cmp",
    "cmp-buffer",
    "cmp-path",
    "cmp_luasnip",
    "mini.pairs",
    "mini.surround",
    "mini.comment",
    "mini.ai",
  },
  colorscheme = { "catppuccin" }, -- tokyonight should always be enabled
  core = {}, -- dummy preset: core should always be enabled
  editor = {
    "neo-tree.nvim",
    "nvim-spectre",
    "telescope.nvim",
    "flash.nvim",
    "which-key.nvim",
    "gitsigns.nvim",
    "vim-illuminate",
    "mini.bufremove",
    "trouble.nvim",
    "todo-comments.nvim",
  },
  lsp = {
    "nvim-lspconfig",
    "neoconf",
    "neodev",
    "mason.nvim",
    "mason-lspconfig.nvim",
    "cmp-nvim-lsp", -- TODO: see coding, has a cond property!
    "neodev",
    "none-ls",
    "null-ls",
  },
  treesitter = {
    "treesitter",
    "nvim-treesitter-textobjects",
    "nvim-ts-context-commentstring",
  },
  ui = {
    "notify",
    "dressing",
    "bufferline",
    "lualine",
    "indent-blankline",
    "indentscope",
    "noice",
    "alpha",
    "navic",
    "web-devicons",
    "nui.nvim",
  },
  util = {
    "vim-startuptime",
    "persistence.nvim",
    "plenary.nvim",
  },
}

local when_enabling = {
  coding = {
    "treesitter",
    "nvim-treesitter-textobjects", -- mini.ai
    "nvim-ts-context-commentstring", -- mini.comment
  },
  editor = {
    "nui.nvim", -- neo-tree
    "plenary.nvim", -- neo-tree, telescope
  },
  lsp = {
    "plenary.nvim", -- none-ls
  },
}

M.get = function(name, enable_on_match)
  local result = presets[name]
  if not result then
    return {}
  end

  if enable_on_match then
    local extra = when_enabling[name]
    if extra then
      result = vim.list_extend({}, result)
      result = vim.list_extend(result, extra)
    end
  end
  return result
end

return M
