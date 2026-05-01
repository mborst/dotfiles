local map = vim.keymap.set
local custom = require("custom")

-- Smart way to move between splits
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })

-- When history searching, use prefix for C-P and C-N
map("c", "<C-p>", "<Up>")
map("c", "<C-n>", "<Down>")

-- Toggle highlight of search results
map("n", "<C-n>", function()
  vim.opt.hlsearch = not vim.opt.hlsearch:get()
end, { silent = true })

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
