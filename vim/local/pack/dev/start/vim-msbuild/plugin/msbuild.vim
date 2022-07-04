
if !has('win32')
	finish
endif

let g:loaded_msbuild = 1

function! MSBuild(q_args, cwd) abort
	let args = a:q_args
	if empty(args)
		let path = findfile('msbuild.xml', ';')
		if filereadable(path)
			let args = printf('/nologo "%s"', path)
		endif
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
			let enc_from = ''
			if encoding#contains_multichar(lines[i])
				if encoding#is_utf8(lines[i])
					let enc_from = 'utf-8'
				else
					let enc_from = 'shift_jis'
				endif
			endif
			if !empty(enc_from) && (enc_from != &encoding)
				let lines[i] = iconv(lines[i], enc_from, &encoding)
			endif
		endfor
	finally
		if filereadable(path)
			call delete(path)
		endif
	endtry
	return lines
endfunction

command! -complete=file -nargs=* MSBuild :call MSBuild(<q-args>, getcwd())

