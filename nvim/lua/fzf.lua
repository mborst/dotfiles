-- fzf.lua — thin wrapper around ibhagwan/fzf-lua to register keymaps and
-- user commands matching the old custom module's interface.
local M = {}

function M.setup()
  local fzf = require("fzf-lua")

  local rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/'"

  fzf.setup({
    -- Use the same tokyonight fzf color scheme (fzf-lua reads
    -- FZF_DEFAULT_OPTS automatically, but we can also set it explicitly).
    fzf_opts = { ["--layout"] = "reverse" },
    winopts = {
      height = 0.85,
      width = 0.9,
      border = "rounded",
      preview = {
        default = "bat",
        border = "border",
        layout = "horizontal",
        horizontal = "right:60%",
      },
    },
    grep = { rg_opts = rg_opts },
    files = {
      fd_opts = nil, -- use rg
      rg_opts = "--files --hidden --glob '!.git/'",
    },
  })

  local map = vim.keymap.set
  local ucmd = vim.api.nvim_create_user_command

  -- User commands
  ucmd("Rg", function(opts) fzf.grep({ search = opts.args }) end, { nargs = "*", desc = "Ripgrep + fzf" })
  ucmd("Mappings", fzf.keymaps, { desc = "fzf: normal-mode keymaps" })
  ucmd("Symbols", function(opts) fzf.lsp_workspace_symbols({ query = opts.args }) end,
    { nargs = "*", desc = "fzf: LSP workspace symbols" })
  ucmd("Definitions", fzf.lsp_definitions, { desc = "fzf: LSP definitions" })
  ucmd("Implementations", fzf.lsp_implementations, { desc = "fzf: LSP implementations" })
  ucmd("TypeDefinitions", fzf.lsp_typedefs, { desc = "fzf: LSP type definitions" })
  ucmd("Diagnostics", function() fzf.diagnostics_document() end, { desc = "fzf: diagnostics (current buffer)" })

  -- File / buffer / window pickers
  map("n", "<leader>f", fzf.files, { desc = "fzf: files" })
  map("n", "<leader>b", fzf.buffers, { desc = "fzf: buffers" })
  map("n", "<leader>w", fzf.tabs, { desc = "fzf: windows/tabs" })
  map("n", "<leader>:", fzf.command_history, { desc = "fzf: command history" })
  map("n", "<leader>m", fzf.keymaps, { desc = "fzf: keymaps" })

  -- Grep pickers
  map("n", "<leader>a", fzf.live_grep, { desc = "fzf: live grep" })
  map("n", "<leader>A", fzf.grep_cword, { desc = "fzf: grep word under cursor" })
  map("v", "<leader>A", fzf.grep_visual, { desc = "fzf: grep visual selection" })
  map("n", "<leader>Ab", function() fzf.grep_cword({ rg_opts = rg_opts .. " -w" }) end,
    { desc = "fzf: grep word (boundary)" })
  map("v", "<leader>Ab", function() fzf.grep_visual({ rg_opts = rg_opts .. " -w" }) end,
    { desc = "fzf: grep visual (boundary)" })

  -- LSP pickers
  map("n", "<leader>lr", fzf.lsp_references, { desc = "fzf: LSP references" })
  map("n", "<leader>ls", fzf.lsp_document_symbols, { desc = "fzf: LSP document symbols" })
  map("n", "<leader>lS", fzf.lsp_workspace_symbols, { desc = "fzf: LSP workspace symbols" })
  map("n", "<leader>ld", fzf.diagnostics_document, { desc = "fzf: diagnostics (current buffer)" })
  map("n", "<leader>lD", fzf.diagnostics_workspace, { desc = "fzf: diagnostics (all buffers)" })
end

return M
