"
" https://github.com/BurntSushi/ripgrep
"

let g:loaded_rg = 1

let s:TYPE_SEARCH = 1
let s:TYPE_KILL = 2

let s:job_id = get(s:, 'job_id', v:null)
let s:cmd_type = get(s:, 'cmd_type', s:TYPE_SEARCH)

command! -nargs=* RgSearch  :call s:rg_exec(s:TYPE_SEARCH, <q-args>)
command! -nargs=0 RgKill    :call s:rg_exec(s:TYPE_KILL, '')

function! s:rg_exec(cmd_type, q_args) abort
	let s:cmd_type = a:cmd_type

	if !executable('rg')
		echo "[rg] Could not find the 'rg' file."
		return
	endif

	if v:null != s:job_id
		if has('nvim')
			call jobstop(s:job_id)
		else
			call job_stop(s:job_id, 'kill')
		endif
		if s:TYPE_KILL == a:cmd_type
			echo '[rg] Killed the process.'
		endif
		let s:job_id = v:null
	else
		if s:TYPE_KILL == a:cmd_type
			echo '[rg] There was nothing to kill.'
		endif
	endif

	if s:TYPE_SEARCH == a:cmd_type
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
	endif
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
	if s:cmd_type == s:TYPE_SEARCH
		echo '[rg] The search has been completed! Please open the quickfix window.'
	endif
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

