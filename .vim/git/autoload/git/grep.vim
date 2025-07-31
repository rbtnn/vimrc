
function! git#grep#exec(q_args) abort
  if !git#check_git()
    return
  endif

  let rootdir = git#get_rootdir()
  let xs = []
  for line in git#git_system(rootdir, ['grep', '-n', '--column', '-r'] + split(a:q_args, '\s\+'))
    let m = matchlist(line, '^\(.\+\):\(\d\+\):\(\d\+\):\(.*\)$')
    if !empty(m)
      let xs += [{
        \ 'filename': m[1],
        \ 'lnum': str2nr(m[2]),
        \ 'col': str2nr(m[3]),
        \ 'text': m[4],
        \ }]
    else
      let xs += [{
        \ 'text': line,
        \ }]
    endif
  endfor
  call setqflist(xs)
  copen
endfunction
