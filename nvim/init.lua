-- Plugin manifest first: vim.pack.add() must run before any plugin
-- code is required (e.g. cmp, lspconfig, fzf wrapper).
require("plugins")

require("config.options")
require("config.slime")
require("config.mappings")
require("config.autocmds")
require("config.filetypes")

-- Colorscheme last so that the MyColors ColorScheme autocmd is already
-- registered when tokyonight fires it.
vim.cmd.colorscheme("tokyonight-night")

require("fzf").setup()
require("quicker").setup({
  -- quicker.nvim doesn't bind any keys by default. Map > / < inside
  -- the qf buffer to grow / shrink the surrounding context.
  keys = {
    { ">", function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end, desc = "Expand qf context" },
    { "<", function() require("quicker").collapse() end, desc = "Collapse qf context" },
  },
})
require("lsp")
require("completion")
