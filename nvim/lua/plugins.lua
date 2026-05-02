-- Plugin manifest, managed by built-in vim.pack (nvim 0.12+).
--
-- vim.pack clones each plugin into ~/.local/share/nvim/site/pack/core/opt/
-- and adds it to the runtimepath synchronously. First startup will fetch
-- all plugins; subsequent startups are a no-op.
--
-- Update with: :lua vim.pack.update()
-- Show status: :lua = vim.pack.get()
vim.pack.add({
  -- tpope core
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/tpope/vim-rhubarb" },
  { src = "https://github.com/tpope/vim-abolish" },
  { src = "https://github.com/tpope/vim-surround" },
  { src = "https://github.com/tpope/vim-repeat" },

  -- ui / theme
  { src = "https://github.com/folke/tokyonight.nvim" },

  -- editing
  { src = "https://github.com/sbdchd/neoformat" },
  { src = "https://github.com/jpalardy/vim-slime" },

  -- quickfix UX (line context, edit-in-place, file grouping). Quickfix
  -- navigation itself uses native :cnext/:lnext mapped in mappings.lua.
  { src = "https://github.com/stevearc/quicker.nvim" },

  -- treesitter (using the new 'main' branch rewrite; parser-only, no
  -- legacy configs.setup API). Queries live under <plugin>/runtime/
  -- which is NOT on rtp by default; we add it manually below.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },

  -- LSP defaults (per-server lsp/<name>.lua picked up by vim.lsp.enable).
  { src = "https://github.com/neovim/nvim-lspconfig" },

  -- completion (nvim-cmp + sources). Snippet engine is built-in vim.snippet.
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/hrsh7th/cmp-cmdline" },
})

-- nvim-treesitter main branch ships its bundled queries under
-- <plugin>/runtime/queries/, not <plugin>/queries/. vim.pack puts only
-- <plugin>/ on rtp, so vim.treesitter.query.get() can't find them.
-- Append the runtime dir for both treesitter plugins.
for _, name in ipairs({ "nvim-treesitter", "nvim-treesitter-textobjects" }) do
  local rtp_extra = vim.fn.stdpath("data") .. "/site/pack/core/opt/" .. name .. "/runtime"
  if vim.fn.isdirectory(rtp_extra) == 1 then
    vim.opt.rtp:append(rtp_extra)
  end
end
