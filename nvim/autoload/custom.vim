"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete all hidden buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
