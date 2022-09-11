
let g:loaded_msbuild = 1

if has('win32') && executable('msbuild')
	let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")

	command! -complete=customlist,MSBuildComp -nargs=* MSBuild :call MSBuild(eval(g:msbuild_projectfile), <q-args>)

	function! MSBuild(projectfile, args) abort
		let path = a:projectfile
		if type([]) == type(a:args)
			let cmd = ['msbuild']
			if filereadable(path)
				let cmd += ['/nologo', path] + a:args
			else
				let cmd += ['/nologo'] + a:args
			endif
		else
			let cmd = printf('msbuild /nologo %s %s', a:args, path)
		endif
		call qfjob#start('msbuild', cmd, function('s:line_parser'))
	endfunction

	function s:line_parser(line) abort
		let m = matchlist(a:line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)\[\(.*\)\]$')
		if !empty(m)
			let path = m[1]
			if !filereadable(path) && (path !~# '^[A-Z]:')
				let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
			endif
			return qfjob#match(path, m[2], m[3], printf('%s[%s]', m[4], m[5]))
		else
			return qfjob#do_not_match(a:line)
		endif
	endfunction

	function! MSBuildComp(A, L, P) abort
		let xs = []
		let path = eval(g:msbuild_projectfile)
		if filereadable(path)
			for line in readfile(path)
				let m = matchlist(line, '<Target\s\+Name="\([^"]\+\)"')
				if !empty(m)
					let xs += ['/t:' .. m[1]]
				endif
			endfor
		endif
		return xs
	endfunction
endif

