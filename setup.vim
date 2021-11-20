let s:lines = [$MYVIMRC, $VIMRC_ROOT, $VIMRC_VIM, $VIMRC_PACKSTART]
try
  "source ./.vimrc
  PlugUpdate --sync
  function! s:is_installed(name) abort
    return isdirectory($VIMRC_PACKSTART .. '/' .. a:name) && (-1 != index(keys(g:plugs), a:name))
  endfunction
  for s:key in keys(g:plugs)
    let s:lines += [string(g:plugs[s:key]), s:is_installed(s:key)]
  endfor
catch
  let s:lines += [v:exception]
endtry
call writefile(s:lines, 'plugs.log')
