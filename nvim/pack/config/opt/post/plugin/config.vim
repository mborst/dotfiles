set termguicolors
set background=light
colorscheme gruvbox
let g:gruvbox_contrast_dark='medium'
let g:gruvbox_contrast_light='medium'

" 'jpalardy/vim-slime'
let g:slime_target = "tmux"
let g:slime_paste_file = tempname()

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

" NEOMAKE
let g:neomake_open_list=2
call neomake#configure#automake('nw', 1000)
nnoremap tnm :NeomakeToggle<CR>
