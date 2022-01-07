"
" https://github.com/BurntSushi/ripgrep
"
if !executable('rg')
	finish
endif

let g:loaded_rg = 1

let s:job_id = get(s:, 'job_id', v:null)

command! -bang -nargs=* Rg     :call s:rg_exec(<q-bang>, <q-args>)

function! s:rg_exec(q_bang, q_args) abort
	try
		if v:null != s:job_id
			if a:q_bang == '!'
				if has('nvim')
					call jobstop(s:job_id)
				else
					call job_stop(s:job_id, 'kill')
				endif
				let s:job_id = v:null
			else
				throw "Rg is running now. If you want to search again, please specify with '!'."
			endif
		endif

		if empty(a:q_args)
			throw "Please give a search text!"
		endif

		let cmd = printf('rg --vimgrep --line-buffered %s .', a:q_args)
		call setqflist([], ' ', { 'title': cmd, })
		if has('nvim')
			let s:job_id = jobstart(cmd, {
				\ 'on_stdout': function('s:nvim_out_cb'),
				\ 'on_stderr': function('s:nvim_out_cb'),
				\ 'on_exit': function('s:nvim_close_cb'),
				\ })
		else
			let s:job_id = job_start(cmd, {
				\ 'err_io': 'out',
				\ 'out_io': 'pipe',
				\ 'out_cb': function('s:vim_out_cb'),
				\ 'exit_cb': function('s:vim_exit_cb'),
				\ })
		endif
	catch
		echohl Error
		echo printf('[rg] %s', v:exception)
		echohl None
	endtry
endfunction

function! s:vim_out_cb(channel, msg) abort
	let line = a:msg
	if !empty(line)
		let m = matchlist(line, '^\([^:]\+\):\(\d\+\):\(\d\+\):\(.*\)$')
		if !empty(m)
			call setqflist([{
				\ 'filename': m[1],
				\ 'lnum': m[2],
				\ 'col': m[3],
				\ 'text': m[4],
				\ }], 'a')
		else
			call setqflist([{ 'text': line, }], 'a')
		endif
	endif
endfunction

function! s:vim_exit_cb(job, status) abort
	echo '[rg] The search has been completed! Please open the quickfix window.'
	let s:job_id = v:null
endfunction

if has('nvim')
	function! s:nvim_out_cb(job, data, event) abort
		for line in a:data
			call s:vim_out_cb(a:job, line)
		endfor
	endfunction

	function! s:nvim_close_cb(job, data, event) abort
		call s:vim_exit_cb(a:job, a:event)
	endfunction
endif
