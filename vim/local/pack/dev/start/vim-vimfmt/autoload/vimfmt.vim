
let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'

function! vimfmt#buffer(q_bang, q_args) abort
  let lines = vimfmt#core#format(getline(1, '$'))
  let pos = getpos('.')
  if line('$') == len(lines)
    for lnum in range(1, len(lines))
      if getline(lnum) != lines[lnum - 1]
        call setline(lnum, lines[lnum - 1])
      endif
    endfor
  else
    silent! call deletebufline(bufnr(), 1, '$')
    call setline(1, lines)
  endif
  call setpos('.', pos)
endfunction

function! vimfmt#run_tests() abort
  if filereadable(s:TEST_LOG)
    call delete(s:TEST_LOG)
  endif

  let v:errors = []

  call vimfmt#tests#basics#run_tests()

  if !empty(v:errors)
    let lines = []
    for err in v:errors
      let xs = split(err, '\(Expected\|but got\)')
      echohl Error
      if 3 == len(xs)
        let lines += [
          \ xs[0],
          \ '  Expected ' .. xs[1],
          \ '  but got  ' .. xs[2],
          \ ]
        echo xs[0]
        echo '  Expected ' .. xs[1]
        echo '  but got  ' .. xs[2]
      else
        let lines += [err]
        echo err
      endif
      echohl None
    endfor
    call writefile(lines, s:TEST_LOG)
  endif
endfunction
