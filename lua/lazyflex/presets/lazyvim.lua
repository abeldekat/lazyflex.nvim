local M = {}

M.presets = {
  coding = {
    "LuaSnip",
    "friendly-snippets",
    "nvim-cmp",
    "cmp-nvim-lsp",
    "cmp-buffer",
    "cmp-path",
    "cmp_luasnip",
    "mini.pairs",
    "mini.surround",
    "nvim-ts-context-commentstring",
    "mini.comment",
    "mini.ai",
  },
  colorscheme = { "tokyonight", "catppuccin" },
  editor = {
    "neo-tree.nvim",
    "nvim-spectre",
    "telescope.nvim",
    "telescope-fzf-native.nvim",
    "flash.nvim",
    "which-key.nvim",
    "gitsigns.nvim",
    "vim-illuminate",
    "mini.bufremove",
    "trouble.nvim",
    "todo-comments.nvim",
  },
  formatting = { "conform.nvim" },
  linting = { "nvim-lint" },
  lsp = {
    "nvim-lspconfig",
    "neoconf",
    "neodev",
    "mason.nvim",
    "mason-lspconfig.nvim",
  },
  treesitter = {
    "treesitter",
    "nvim-treesitter-textobjects",
    "nvim-treesitter-context",
    "nvim-ts-autotag",
  },
  ui = {
    "notify",
    "dressing",
    "bufferline",
    "lualine",
    "indent-blankline",
    "indentscope",
    "noice",
    "web-devicons",
    "nui.nvim",
    "dashboard-nvim",
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
  formatting = { "mason.nvim" },
  linting = { "mason.nvim" },
  lsp = {
    "plenary.nvim", -- none-ls
  },
}

return M
