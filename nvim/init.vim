""""""""""""""""""""
" General settings
""""""""""""""""""""
set rtp+=/usr/local/opt/fzf

set lazyredraw

set ignorecase
set smartcase

"set formatoptions=qrn1
set formatoptions=crqM1j
set encoding=utf-8 " use UTF-8 encoding
set number " always show line numbers
set ruler
set nowrap
set nocursorline
set colorcolumn=+1 " highlight column after 'textwidth'
set scrolloff=25
set nojoinspaces
set foldmethod=syntax
set nofoldenable

" Global settings for all files (but may be overridden in ftplugin).
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set nocindent

set backspace=2

set mouse=a

set wildmenu wildmode=longest,list

set noautochdir

set incsearch
set hlsearch

set showcmd
set showmatch

" Spellchecking
setlocal spelllang=en

" More natural splits
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.

set hidden

set grepprg=rg\ --vimgrep      " use ripgrep

" Add the g flag to search/replace by default
set gdefault

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Only allow backspacing what has been written since entering insert mode
" set backspace=indent,eol

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Undo and swap
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Centralize backups, swapfiles and undo history
set backupdir=~/.cache/nvim/backups
set directory=~/.cache/nvim/swaps
" Save undo's after file closes
set undofile
set undodir=~/.cache/nvim/undo
set undolevels=1000         " How many undos
set undoreload=10000        " number of lines to save for undo

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Completion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set completeopt=menuone,noinsert,noselect

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Netrw
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:netrw_banner=0
let g:netrw_liststyle=0
let g:netrw_preview=1
let g:netrw_winsize=15

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Smart way to move between splits
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l

" When history searching, use prefix for C-P and C-N
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Toggle highlight of search results
nnoremap <C-n> :set hlsearch!<CR>

" Find and replace word under cursor
nnoremap <Leader>sr :%s/\<<C-r><C-w>\>//<Left>
vnoremap <leader>sr y:%s/\<<C-r>"\>//<Left>

nnoremap <leader>a :Rg<Space>
nnoremap <leader>A :Rg<Space><C-R><C-W>
vnoremap <leader>A y:Rg <C-r>"<CR>
nnoremap <leader>Ab :Rg<Space>\b<C-R><C-W>\b<CR>
vnoremap <leader>Ab y:Rg \b<C-r>"\b<CR>

nnoremap <leader>v :vsplit<CR>
nnoremap <leader>h :split<CR>
nnoremap <leader>Q :bdelete<CR>

nnoremap <leader>e :Explore<CR>

" Map jj to go to normal mode
inoremap jj <ESC>

" Delete hidden buffers
nnoremap dhb :call custom#DeleteHiddenBuffers()<CR>

" Open all files in quickfix list
command! QuickFixOpenAll call custom#QuickFixOpenAll()

" Needed on MacOs to be able to edit crontabs
autocmd filetype crontab setlocal nobackup nowritebackup

autocmd BufNewFile,BufRead *.sky set filetype=bzl

" Avro schemas are jsons
autocmd BufNewFile,BufRead *.avsc setfiletype json syntax=json

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Status Line
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2
set statusline=
set statusline+=%f\                           " filename
set statusline+=\ %h%m%r%w                    " status flags
set statusline+=(\ %l/%L,\ %c\ )              " line, character
set statusline+=%=                            " right align remainder

set statusline+=\ %{fugitive\#statusline()}

if has('statusline')
  set title titlestring=nvim\ %F
endif

set cmdheight=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Clipboard
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set clipboard=unnamed
nnoremap <leader>p :let @+=@"<CR>
nnoremap <leader>P :let @+=@%<CR>

autocmd FileType make set noexpandtab shiftwidth=4 softtabstop=0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Handle files that changed on disk in neovim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/neovim/neovim/issues/2127#issuecomment-150954047
augroup AutoSwap
  autocmd!
  autocmd SwapExists *  call AS_HandleSwapfile(expand('<afile>:p'),
        \ v:swapname)
augroup END

function! AS_HandleSwapfile (filename, swapname)
  " if swapfile is older than file itself, just get rid of it
  if getftime(v:swapname) < getftime(a:filename)
    call delete(v:swapname)
    let v:swapchoice = 'e'
  endif
endfunction

autocmd CursorHold,BufWritePost,BufReadPost,BufLeave *
  \ if isdirectory(expand("<amatch>:h")) | let &swapfile = &modified | endif

augroup checktime
  autocmd!
  if !has("gui_running")
    "silent! necessary otherwise throws errors when using command
    "line window.
    autocmd BufEnter,CursorHold,CursorHoldI,CursorMoved,CursorMovedI,FocusGained,BufEnter,FocusLost,WinLeave * checktime
  endif
augroup END
