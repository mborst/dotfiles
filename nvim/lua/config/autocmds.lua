local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

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
    vim.cmd("checktime")
  end,
})

