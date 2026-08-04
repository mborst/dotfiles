local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Start treesitter highlighting for any buffer whose filetype has an
-- available parser. nvim-treesitter's 'main' branch only manages parser
-- installation; it does not auto-enable highlighting. With LSP semantic
-- tokens disabled in lsp.lua, treesitter is the sole syntax highlighter.
autocmd("FileType", {
  group = augroup("UserTreesitterStart", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Re-apply custom Comment highlight on every :colorscheme change.
local my_colors = augroup("MyColors", { clear = true })
autocmd("ColorScheme", {
  group = my_colors,
  pattern = "*",
  callback = function()
    vim.cmd("highlight Comment ctermbg=NONE ctermfg=101 cterm=NONE guibg=NONE guifg=#87875f gui=NONE")
  end,
})

local smart_swapfile = augroup("SmartSwapfile", { clear = true })
autocmd({ "BufReadPost", "BufNewFile" }, {
  group = smart_swapfile,
  pattern = "*",
  callback = function()
    if vim.bo.buftype ~= "" then
      vim.opt_local.swapfile = false
    end
  end,
})

local auto_checktime = augroup("AutoChecktime", { clear = true })
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = auto_checktime,
  pattern = "*",
  callback = function()
    -- :checktime is invalid in the command-line window.
    if vim.fn.getcmdwintype() ~= "" then
      return
    end

    vim.cmd("checktime")
  end,
})

