
if !has('win32')
	finish
endif

let g:loaded_msbuild = 1

let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")

function! MSBuild(q_args, cwd) abort
	let path = eval(g:msbuild_projectfile)
	if filereadable(path)
		let args = printf('/nologo "%s" %s', path, a:q_args)
	else
		let args = printf('/nologo %s', a:q_args)
	endif

	let lines = s:system('msbuild ' .. args, a:cwd)

	let xs = []
	for line in lines
		let m = matchlist(line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)\[\(.*\)\]$')
		if !empty(m)
			let path = m[1]
			if !filereadable(path) && (path !~# '^[A-Z]:')
				let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
			endif
			let xs += [{
				\ 'filename': path,
				\ 'lnum': m[2],
				\ 'col': m[3],
				\ 'text': printf('%s[%s]', m[4], m[5]),
				\ }]
		else
			let xs += [{ 'text': line, }]
		endif
	endfor
	call setqflist(xs)
	copen
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

function s:system(cmd, cwd) abort
	let lines = []
	let path = tempname()
	try
		let job = job_start(a:cmd, {
			\ 'cwd': a:cwd,
			\ 'out_io': 'file',
			\ 'out_name': path,
			\ 'err_io': 'out',
			\ })
		while 'run' == job_status(job)
		endwhile
		if filereadable(path)
			let lines = readfile(path)
		endif
		for i in range(0, len(lines) - 1)
			let lines[i] = qficonv#encoding#iconv_utf8(lines[i], 'shift_jis')
		endfor
	finally
		if filereadable(path)
			call delete(path)
		endif
	endtry
	return lines
endfunction

command! -complete=customlist,MSBuildComp -nargs=* MSBuild :call MSBuild(<q-args>, getcwd())

