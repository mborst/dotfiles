vim.filetype.add({
  extension = {
    sky = "bzl",
    avsc = "json",
  },
  filename = {
    ["Dockerfile"] = "dockerfile",
  },
  pattern = {
    ["Dockerfile%..*"] = "dockerfile",
  },
})

-- Per-filetype local options (replaces nvim/ftplugin/*.vim)
local function ftset(filetypes, opts)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = function()
      for k, v in pairs(opts) do
        vim.opt_local[k] = v
      end
    end,
  })
end

ftset({ "bzl" },             { tabstop = 4, shiftwidth = 4 })
ftset({ "gitconfig", "go" }, { expandtab = false })
ftset({ "make" },            { expandtab = false, tabstop = 4, shiftwidth = 4, softtabstop = 0 })
ftset({ "markdown" },        { textwidth = 100, colorcolumn = "100" })
-- macOS crontab rejects edits if backup files are created
ftset({ "crontab" },         { backup = false, writebackup = false })
