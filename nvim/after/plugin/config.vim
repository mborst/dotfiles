set termguicolors
set background=dark

function! MyHighlights() abort
    highlight Comment ctermbg=NONE ctermfg=101 cterm=NONE guibg=NONE guifg=#87875f gui=NONE
endfunction

augroup MyColors
    autocmd!
    autocmd ColorScheme * call MyHighlights()
augroup END

colorscheme tokyonight

" 'romainl/vim-qf'
map <leader>l <Plug>QfLnext
map <leader>L <Plug>QfLprevious
map <leader>n <Plug>QfCnext
map <leader>N <Plug>QfCprevious

" Causes issues with resizing (https://github.com/vim/vim/issues/931).
let g:qf_loclist_window_bottom = 0
let g:qf_window_bottom = 0

let g:qf_auto_open_quickfix = 0
let g:qf_auto_open_loclist = 0

" fugitive
nnoremap <leader>gl :Git log --oneline -20<CR>

" LSP
lua << EOF
require'lsp'
EOF

" treesitter
" Highlighting and indent are built-in in Neovim 0.11+;
" nvim-treesitter plugin now only manages parser installation.

set foldmethod=expr
set foldexpr=v:lua.vim.treesitter.foldexpr()

" Completion
lua << EOF
require'completion'
EOF


set textwidth=100
set colorcolumn=100
set conceallevel=0
