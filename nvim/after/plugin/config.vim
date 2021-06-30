set termguicolors
set background=dark
colorscheme apprentice

" 'romainl/vim-qf'
map <leader>l <Plug>QfLnext
map <leader>L <Plug>QfLprevious
map <leader>c <Plug>QfCnext
map <leader>C <Plug>QfCprevious

" Causes issues with resizing (https://github.com/vim/vim/issues/931).
let g:qf_loclist_window_bottom = 0
let g:qf_window_bottom = 0

" Annoying with Neomake, but only on Vim?!
" Even with let `g:neomake_open_list = 2` !
let g:qf_auto_open_quickfix = 0
let g:qf_auto_open_loclist = 0

" 'junegunn/rainbow_parentheses.vim'
augroup rainbow_langs
  autocmd!
  autocmd FileType go,javascript,lisp,clojure,scheme,vim,sh,terraform RainbowParentheses
augroup END
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

" 'terryma/vim-expand-region'
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

" fzf
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>w :Windows<CR>
nnoremap <leader>: :History:<CR>

" gitgutter
let g:gitgutter_grep = 'rg'

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
"lua <<EOF
"require'nvim-treesitter.configs'.setup {
"  ensure_installed = {},
"  ignore_install = {},
"  modules = {
"    highlight = {
"      additional_vim_regex_highlighting = false,
"      custom_captures = {},
"      disable = { "markdown" },
"      enable = true,
"      module_path = "nvim-treesitter.highlight"
"    },
"    incremental_selection = {
"      enable = true,
"      keymaps = {
"        init_selection = "gnn",
"        node_decremental = "grm",
"        node_incremental = "grn",
"        scope_incremental = "grc"
"      },
"      module_path = "nvim-treesitter.incremental_selection"
"    },
"    indent = {
"      disable = {},
"      enable = true,
"      module_path = "nvim-treesitter.indent"
"    }
"  },
"}
"EOF

" Completion
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
let g:completion_trigger_keyword_length = 3
let g:completion_chain_complete_list = [
    \{'complete_items': ['lsp']},
    \{'mode': '<c-p>'},
    \{'mode': '<c-n>'}
\]
set completeopt=menuone,noinsert,noselect
set shortmess+=c
