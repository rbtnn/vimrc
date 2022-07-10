
if !executable('rg')
	finish
endif

let g:loaded_ripgrep = 1

function! Ripgrep(q_args) abort
	call setqflist([], 'r')
	let job = job_start(['rg', '--vimgrep', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : []), {
		\ 'out_cb': function('s:out_cb'),
		\ 'err_io': 'out',
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
	let m = matchlist(line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
	if !empty(m)
		let path = m[1]
		if !filereadable(path) && (path !~# '^[A-Z]:')
			let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
		endif
		let x = [{
			\ 'filename': path,
			\ 'lnum': m[2],
			\ 'col': m[3],
			\ 'text': m[4],
			\ }]
	else
		let x = [{ 'text': line, }]
	endif
	call setqflist(x, 'a')
endfunction

command! -nargs=* Ripgrep :call Ripgrep(<q-args>)

