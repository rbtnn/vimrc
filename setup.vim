PlugUpdate --sync
let s:lines = [$VIMRC_ROOT, $VIMRC_VIM, $VIMRC_PACKSTART]
for s:key in keys(g:plugs)
	let s:lines += [string(g:plugs[s:key]), s:is_installed(s:key)]
endfor
call writefile(s:lines, 'plugs.log')
