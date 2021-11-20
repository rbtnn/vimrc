PlugUpdate --sync
function! s:is_installed(name) abort
	return isdirectory($VIMRC_PACKSTART .. '/' .. a:name) && (-1 != index(keys(g:plugs), a:name))
endfunction
let s:lines = [$MYVIMRC, $VIMRC_ROOT, $VIMRC_VIM, $VIMRC_PACKSTART]
for s:key in keys(g:plugs)
	let s:lines += [string(g:plugs[s:key]), s:is_installed(s:key)]
endfor
call writefile(s:lines, 'plugs.log')
