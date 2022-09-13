
let g:loaded_gitgrep = 1

if executable('git')
	command! -nargs=* GitGrep :call GitGrep(<q-args>)

	function! GitGrep(q_args) abort
		let cmd = ['git', '--no-pager', 'grep', '--no-color', '-n'] + split(a:q_args, '\s\+')
		call qfjob#start('git grep', cmd, function('s:line_parser'))
	endfunction

	function s:line_parser(line) abort
		let m = matchlist(a:line, '^\(.\{-\}\):\(\d\+\):\(.*\)$')
		if !empty(m)
			let path = m[1]
			if !filereadable(path) && (path !~# '^[A-Z]:')
				let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
			endif
			return qfjob#match(path, m[2], -1, m[3])
		else
			return qfjob#do_not_match(a:line)
		endif
	endfunction
endif
