local M = {}

M.presets = {
  coding = {
    "LuaSnip",
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
  colorscheme = { "tokyonight", "catppuccin" },
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
    "cmp-nvim-lsp",
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

M.when_enabling = {
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

return M
