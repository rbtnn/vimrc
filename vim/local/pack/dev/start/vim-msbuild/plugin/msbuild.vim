
if !has('win32') || !executable('msbuild')
	finish
endif

let g:loaded_msbuild = 1

let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")

function! MSBuild(projectfile, args, cwd) abort
	if exists('g:loaded_qficonv')
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
		call setqflist([], 'r')
		let job = job_start(cmd, {
			\ 'out_cb': function('s:out_cb'),
			\ 'err_io': 'out',
			\ 'cwd': a:cwd,
			\ })
		call s:waitting(job)
		copen
	else
		echohl ErrorMsg
		echo '[msbuild] Please install rbtnn/vim-qficonv!'
		echohl None
	endif
endfunction

function s:waitting(job) abort
	try
		let i = 0
		while 'run' == job_status(a:job)
			let i = (i + 1) % 4
			redraw
			echo '[msbuild] The job is running ' .. ['-', '\', '|', '/'][i]
			sleep 50m
		endwhile
		redraw
		echo '[msbuild] The job has finished!'
	catch /^Vim:Interrupt$/
		call job_stop(a:job, 'kill')
		echohl ErrorMsg
		echo '[msbuild] Interrupt!'
		echohl None
	endtry
endfunction

function s:out_cb(ch, msg) abort
	let line = a:msg
	let m = matchlist(line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)\[\(.*\)\]$')
	if !empty(m)
		let path = m[1]
		if !filereadable(path) && (path !~# '^[A-Z]:')
			let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
		endif
		let x = [{
			\ 'filename': qficonv#encoding#iconv_utf8(path, 'shift_jis'),
			\ 'lnum': m[2],
			\ 'col': m[3],
			\ 'text': qficonv#encoding#iconv_utf8(printf('%s[%s]', m[4], m[5]), 'shift_jis'),
			\ }]
	else
		let x = [{ 'text': qficonv#encoding#iconv_utf8(line, 'shift_jis'), }]
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

command! -complete=customlist,MSBuildComp -nargs=* MSBuild :call MSBuild(eval(g:msbuild_projectfile), <q-args>, getcwd())

