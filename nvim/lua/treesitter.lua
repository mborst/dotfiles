-- nvim-treesitter is used primarily for parser installation; highlighting and
-- indent are built-in in Neovim 0.11+. We additionally enable incremental
-- selection here, replacing the old terryma/vim-expand-region plugin.
require("nvim-treesitter.configs").setup({
  incremental_selection = {
    enable = true,
    keymaps = {
      -- start selection of the smallest treesitter node under the cursor
      init_selection = "<leader>v",
      -- in visual mode: grow / shrink selection by treesitter node
      node_incremental = "v",
      node_decremental = "V",
      -- grow by enclosing scope (function, block, ...)
      scope_incremental = "<C-s>",
    },
  },
})
