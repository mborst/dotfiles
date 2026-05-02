require("config.options")
require("config.mappings")
require("config.autocmds")
require("config.filetypes")

-- Colorscheme last so that the MyColors ColorScheme autocmd is already
-- registered when tokyonight fires it.
vim.cmd.colorscheme("tokyonight")

require("fzf").setup()
require("lsp")
require("completion")
