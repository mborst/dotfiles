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

" Annoying with Neomake, but only on Vim?!
" Even with let `g:neomake_open_list = 2` !
let g:qf_auto_open_quickfix = 0
let g:qf_auto_open_loclist = 0

" fzf
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>w :Windows<CR>
nnoremap <leader>: :History:<CR>
nnoremap <leader>ls :DocumentSymbols
nnoremap <leader>ld :DiagnosticsAll<CR>
nnoremap <leader>lr :References<CR>
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob ''!.git/'' -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" fugitive
nnoremap <leader>gl :Git log --oneline -20<CR>
let g:fzf_lsp_timeout=10000

" NEOMAKE
let g:neomake_open_list=2
"call neomake#configure#automake('w', 1000)
nnoremap tnm :NeomakeToggle<CR>
let g:neomake_python_enabled_makers = ['python', 'flake8']

" LSP
lua << EOF
require'lsp'
EOF

" treesitter
" Highlighting and indent are built-in in Neovim 0.11+;
" nvim-treesitter plugin now only manages parser installation.

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" Completion
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
let g:completion_trigger_keyword_length = 3
let g:completion_chain_complete_list = [
    \{'complete_items': ['lsp']},
    \{'mode': '<c-p>'},
    \{'mode': '<c-n>'}
\]

lua << EOF
require'completion'
EOF

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'


set textwidth=100
set colorcolumn=100
set conceallevel=0
