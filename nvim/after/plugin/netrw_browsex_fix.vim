" Neovim 0.12 / netrw changed netrw#BrowseX signature; fugitive's :GBrowse
" still calls it. Force-load netrw's autoload, then override BrowseX to
" delegate to vim.ui.open (which DTRT on macOS/Linux).
silent! call netrw#BrowseX('', 0)
function! netrw#BrowseX(fname, ...) abort
  call luaeval('(function(u) vim.ui.open(u) end)(_A)', a:fname)
endfunction
