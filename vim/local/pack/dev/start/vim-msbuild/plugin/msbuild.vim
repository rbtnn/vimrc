
if !has('win32') || !executable('msbuild')
	finish
endif

let g:loaded_msbuild = 1

let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")

function! MSBuild(q_args, cwd) abort
	let path = eval(g:msbuild_projectfile)
	let cmd = ['msbuild']
	if filereadable(path)
		let cmd += ['/nologo', path, a:q_args]
	else
		let cmd += ['/nologo', a:q_args]
	endif
	call setqflist([], 'r')
	let job = job_start(cmd, {
		\ 'out_cb': function('s:out_cb'),
		\ 'err_io': 'out',
		\ 'cwd': a:cwd,
		\ })
	try
		while 'run' == job_status(job)
			sleep 10m
		endwhile
	catch /^Vim:Interrupt$/
		call job_stop(job, 'kill')
		echohl ErrorMsg
		echo 'Interrupt!'
		echohl None
	endtry
	copen
endfunction

function s:out_cb(ch, msg) abort
	if g:loaded_qficonv
		let line = qficonv#encoding#iconv_utf8(a:msg, 'shift_jis')
	else
		let line = a:msg
	endif
	let m = matchlist(line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)\[\(.*\)\]$')
	if !empty(m)
		let path = m[1]
		if !filereadable(path) && (path !~# '^[A-Z]:')
			let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
		endif
		let x = [{
			\ 'filename': path,
			\ 'lnum': m[2],
			\ 'col': m[3],
			\ 'text': printf('%s[%s]', m[4], m[5]),
			\ }]
	else
		let x = [{ 'text': line, }]
	endif
	call setqflist(x, 'a')
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

command! -complete=customlist,MSBuildComp -nargs=* MSBuild :call MSBuild(<q-args>, getcwd())

