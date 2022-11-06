
let s:job = v:null
let s:items = []

function! qfjob#start(title, cmd, line_parser) abort
	call qfjob#stop()
	cclose
	let s:job = job_start(a:cmd, {
		\ 'exit_cb': function('s:exit_cb', [a:title, a:line_parser]),
		\ 'out_cb': function('s:out_cb'),
		\ 'err_io': 'out',
		\ })
endfunction

function! qfjob#stop() abort
	if s:job != v:null
		if 'run' == job_status(s:job)
			call job_stop(s:job, 'kill')
		endif
	endif
	let s:job = v:null
	let s:items = []
endfunction

function! qfjob#match(path, lnum, col, text) abort
	return {
		\ 'filename': s:iconv(a:path),
		\ 'lnum': a:lnum,
		\ 'col': a:col,
		\ 'text': s:iconv(a:text),
		\ }
endfunction

function! qfjob#do_not_match(line) abort
	return { 'text': s:iconv(a:line), }
endfunction

function s:iconv(text) abort
	if exists('g:loaded_qficonv') && (len(a:text) < 500)
		return qficonv#encoding#iconv_utf8(a:text, 'shift_jis')
	else
		return a:text
	endif
endfunction

function s:out_cb(ch, msg) abort
	let s:items += [a:msg]
endfunction

function s:exit_cb(title, line_parser, job, status) abort
	let xs = []
	try
		for item in s:items
			let p = len(xs) * 100 / len(s:items)
			let xs += [a:line_parser(item)]
			redraw
			echo printf('[%s] The job has finished! Please wait for building the quickfix... (%d%%)', a:title, p)
		endfor
	catch /^Vim:Interrupt$/
		redraw
		echo printf('[%s] Interrupt!', a:title)
	finally
		call setqflist(xs)
		copen
		call qfjob#stop()
	endtry
endfunction

