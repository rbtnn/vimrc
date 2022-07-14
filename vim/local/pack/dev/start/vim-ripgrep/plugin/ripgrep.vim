
if !executable('rg')
	finish
endif

let g:loaded_ripgrep = 1

function! Ripgrep(q_args) abort
	if exists('g:loaded_qficonv')
		call setqflist([], 'r')
		let job = job_start(['rg', '--vimgrep', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : []), {
			\ 'out_cb': function('s:out_cb'),
			\ 'err_io': 'out',
			\ })
		call s:waitting(job)
		copen
	else
		echohl ErrorMsg
		echo '[ripgrep] Please install rbtnn/vim-qficonv!'
		echohl None
	endif
endfunction

function s:waitting(job) abort
	try
		let i = 0
		while 'run' == job_status(a:job)
			let i = (i + 1) % 4
			redraw
			echo '[ripgrep] The job is running ' .. ['-', '\', '|', '/'][i]
			sleep 50m
		endwhile
		redraw
		echo '[ripgrep] The job has finished!'
	catch /^Vim:Interrupt$/
		call job_stop(a:job, 'kill')
		echohl ErrorMsg
		echo '[ripgrep] Interrupt!'
		echohl None
	endtry
endfunction

function s:out_cb(ch, msg) abort
	let line = a:msg
	let m = matchlist(line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
	if !empty(m)
		let path = m[1]
		if !filereadable(path) && (path !~# '^[A-Z]:')
			let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
		endif
		let x = [{
			\ 'filename': qficonv#encoding#iconv_utf8(path, 'shift_jis'),
			\ 'lnum': m[2],
			\ 'col': m[3],
			\ 'text': qficonv#encoding#iconv_utf8(m[4], 'shift_jis'),
			\ }]
	else
		let x = [{ 'text': qficonv#encoding#iconv_utf8(line, 'shift_jis'), }]
	endif
	call setqflist(x, 'a')
endfunction

command! -nargs=* Ripgrep :call Ripgrep(<q-args>)

