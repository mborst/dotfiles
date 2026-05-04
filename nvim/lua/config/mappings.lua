local map = vim.keymap.set
local custom = require("custom")

-- fugitive
map("n", "<leader>gl", "<cmd>Git log --oneline -20<CR>", { silent = true, desc = "Git log (last 20)" })

-- Quickfix / location list navigation (was: vim-qf <Plug>Qf{L,C}{next,prev}).
map("n", "<leader>l", "<cmd>lnext<CR>", { silent = true, desc = "Loclist: next" })
map("n", "<leader>L", "<cmd>lprevious<CR>", { silent = true, desc = "Loclist: previous" })
map("n", "<leader>n", "<cmd>cnext<CR>", { silent = true, desc = "Quickfix: next" })
map("n", "<leader>N", "<cmd>cprevious<CR>", { silent = true, desc = "Quickfix: previous" })

-- Smart way to move between splits (and tmux panes via vim-tmux-navigator)
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true })

-- When history searching, use prefix for C-P and C-N
map("c", "<C-p>", "<Up>")
map("c", "<C-n>", "<Down>")

-- Toggle highlight of search results
map("n", "<leader>hl", function()
  vim.opt.hlsearch = not vim.opt.hlsearch:get()
end, { silent = true, desc = "Toggle hlsearch" })

-- Find and replace word under cursor
map("n", "<leader>sr", custom.substitute_cword)

map("v", "<leader>sr", custom.substitute_visual)

-- Ripgrep mappings
map("n", "<leader>a", custom.rg_prompt_empty)

map("n", "<leader>A", custom.rg_prompt_cword)

map("v", "<leader>A", custom.rg_visual)

map("n", "<leader>Ab", custom.rg_word_boundary_cword, { silent = true })

map("v", "<leader>Ab", custom.rg_word_boundary_visual, { silent = true })

-- Splits and buffer management
map("n", "<leader>v", function()
  vim.cmd.vsplit()
end, { silent = true })

map("n", "<leader>h", function()
  vim.cmd.split()
end, { silent = true })

map("n", "<leader>Q", function()
  vim.cmd.bdelete()
end, { silent = true })

-- Netrw and buffers
map("n", "<leader>e", function()
  vim.cmd.Explore()
end, { silent = true })

map("n", "<leader>bn", function()
  vim.cmd.bnext()
end, { silent = true })

map("n", "<leader>p", function()
  vim.fn.setreg("+", vim.fn.getreg('"'))
end, { silent = true, desc = "Copy unnamed register to clipboard" })

map("n", "<leader>P", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
end, { silent = true, desc = "Copy current file path to clipboard" })

-- Map aa to go to normal mode
map("i", "aa", "<Esc>")

-- Built-in snippet jumps (vim.snippet, nvim 0.10+).
-- Tab / S-Tab jump forward / back when a snippet is active; fall through
-- to the literal key otherwise so cmp's preset.insert keeps working.
map({ "i", "s" }, "<Tab>", function()
  if vim.snippet.active({ direction = 1 }) then
    return "<cmd>lua vim.snippet.jump(1)<CR>"
  end
  return "<Tab>"
end, { expr = true, silent = true })

map({ "i", "s" }, "<S-Tab>", function()
  if vim.snippet.active({ direction = -1 }) then
    return "<cmd>lua vim.snippet.jump(-1)<CR>"
  end
  return "<S-Tab>"
end, { expr = true, silent = true })

-- Delete hidden buffers
map("n", "dhb", custom.delete_hidden_buffers, {
  desc = "Delete hidden buffers",
})

-- Open all files in quickfix list
vim.api.nvim_create_user_command("QuickFixOpenAll", custom.quickfix_open_all, {
  desc = "Open all quickfix items",
})

-- Convert inline yaml into proper yaml for human editing, e.g. for kubectl edit
map("n", "<leader>day", function()
  custom.convert_yaml_keys({ "application.tpl", "application.yaml" })
end, {
  desc = "Convert inline YAML",
})
