" Delete all hidden buffers
function! custom#DeleteHiddenBuffers()
  let l:tpbl=[]
  let l:closed = 0
  call map(range(1, tabpagenr('$')), 'extend(l:tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(l:tpbl, v:val)==-1')
    if getbufvar(buf, '&mod') == 0
      silent execute 'bwipeout' buf
      let l:closed += 1
    endif
  endfor
  echo "Closed ".l:closed." hidden buffers"
endfunction

" quickfixopenall.vim
"Author:
"   Tim Dahlin
"
"Description:
"   Opens all the files in the quickfix list for editing.
"
"Usage:
"   1. Perform a vimgrep search
"       :vimgrep /def/ *.rb
"   2. Issue QuickFixOpenAll command
"       :QuickFixOpenAll
function! custom#QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
    let s:prev_val = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
          execute "edit " . fnameescape(s:curr_val)
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction

" Convert inline yaml into proper yaml for human editing, e.g. for kubectl edit
function! custom#ConvertYamlKeys(keys)
  let l:expr = join(map(copy(a:keys),
        \ {_, k -> '.data["'.k.'"] = (.data["'.k.'"] | from_yaml)'}), ' | ')

  let l:cmd = "yq eval -I2 -P '" . l:expr . "' -"
  let l:output = system(l:cmd, join(getline(1, '$'), "\n"))

  if v:shell_error
    echoerr "yq failed"
    return
  endif

  call setline(1, split(l:output, "\n"))
endfunction
