local opt = vim.opt
local g = vim.g

-- General settings
opt.rtp:append("/opt/homebrew/opt/fzf")

opt.lazyredraw = true

opt.ignorecase = true
opt.smartcase = true

opt.formatoptions = "crqM1j"
opt.encoding = "utf-8"
opt.number = true
opt.ruler = false
opt.wrap = false
opt.cursorline = true
opt.cursorcolumn = true
opt.colorcolumn = "+1"
opt.scrolloff = 25
opt.joinspaces = false
opt.foldmethod = "syntax"
opt.foldenable = false
opt.listchars = {
  eol = "¬",
  tab = ">·",
  trail = "~",
  extends = ">",
  precedes = "<",
  space = "␣",
}

-- Global settings for all files (but may be overridden in ftplugin).
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.cindent = false

opt.backspace = "2"
opt.mouse = "a"

opt.wildmenu = true
opt.wildmode = { "longest", "list" }

opt.autochdir = false

opt.incsearch = true
opt.hlsearch = true

opt.showcmd = true
opt.showmatch = true

-- Spellchecking
opt.spelllang = { "en" }

-- More natural splits
opt.splitbelow = true
opt.splitright = true

opt.hidden = true

opt.grepprg = "rg --vimgrep"

-- Add the g flag to search/replace by default
opt.gdefault = true

-- Choose one value; your init.vim had both 300 and 1000
opt.updatetime = 1000

-- don't give ins-completion-menu messages
opt.shortmess:append("c")

-- Completion
opt.completeopt = { "menuone", "noinsert", "noselect" }

-- Netrw
g.netrw_banner = 0
g.netrw_liststyle = 0
g.netrw_preview = 1
g.netrw_winsize = 15

-- Status line
opt.laststatus = 2
opt.statusline = "%f %m%r%=%(%l/%L, %c%)"
opt.cmdheight = 1

-- Set terminal/window title
opt.title = true
opt.titlestring = "nvim %F"

-- Undo and swap
opt.backupdir = vim.fn.expand("~/.cache/nvim/backups//")
opt.directory = vim.fn.expand("~/.cache/nvim/swaps//")
opt.undofile = true
opt.undodir = vim.fn.expand("~/.cache/nvim/undo")
opt.undolevels = 1000
opt.undoreload = 10000
