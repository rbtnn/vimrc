
function! qfjob#start(title, cmd, line_parser) abort
	if exists('g:loaded_qficonv')
		call setqflist([], 'r')
		call job_start(a:cmd, {
			\ 'out_cb': function('s:out_cb', [a:line_parser]),
			\ 'exit_cb': function('s:exit_cb', [a:title]),
			\ 'err_io': 'out',
			\ })
	else
		echowindow printf('[%s] Please install rbtnn/vim-qficonv!', a:title)
	endif
endfunction

function! qfjob#match(path, lnum, col, text) abort
	return {
		\ 'filename': qficonv#encoding#iconv_utf8(a:path, 'shift_jis'),
		\ 'lnum': a:lnum,
		\ 'col': a:col,
		\ 'text': qficonv#encoding#iconv_utf8(a:text, 'shift_jis'),
		\ }
endfunction

function! qfjob#do_not_match(line) abort
	return { 'text': qficonv#encoding#iconv_utf8(a:line, 'shift_jis'), }
endfunction

function s:out_cb(line_parser, ch, msg) abort
	call setqflist([call(a:line_parser, [a:msg])], 'a')
endfunction

function s:exit_cb(title, job, status) abort
	copen
	echowindow printf('[%s] The job has finished!', a:title)
endfunction
