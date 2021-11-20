PlugUpdate --sync

function! s:main() abort
	let lines = []

	let xs = split('/home/runner/work/vimrc/vimrc/vim/pack/my/start/vim-find', '/')
	let s = '/'
	for x in xs
		let s = s .. x .. '/'
		let lines += [printf('%s: %d', s, isdirectory(s))]
	endfor
	let lines += [printf('%s: %s', '$MYVIMRC', string($MYVIMRC))]
	let lines += [printf('%s: %s', '$VIMRC_ROOT', string($VIMRC_ROOT))]
	let lines += [printf('%s: %s', '$VIMRC_VIM', string($VIMRC_VIM))]
	let lines += [printf('%s: %s', '$VIMRC_PACKSTART', string($VIMRC_PACKSTART))]
	let lines += ['']
	let lines += split(execute('scriptnames'), "\n")
	let lines += ['']
	let lines += split(&runtimepath, ',')
	let lines += ['']
	for name in keys(get(g:, 'plugs', []))
		let lines += [printf('%s(%d): %s', name, isdirectory(g:plugs[name]['dir']), string(g:plugs[name]))]
	endfor
	call writefile(lines, $VIMRC_ROOT .. '/vimrc.log')
endfunction

call s:main()

