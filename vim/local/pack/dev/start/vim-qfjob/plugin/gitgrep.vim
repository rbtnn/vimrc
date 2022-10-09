
let g:loaded_gitgrep = 1

if executable('git')
	command! -nargs=* GitGrep :call GitGrep(<q-args>)

	function! GitGrep(q_args) abort
		let cmd = ['git', '--no-pager', 'grep', '--no-color', '-n', '--column'] + split(a:q_args, '\s\+')
		call qfjob#start('git grep', cmd, function('s:line_parser'))
	endfunction

	function s:line_parser(line) abort
		let m = matchlist(a:line, '^\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
		if !empty(m)
			let path = m[1]
			if !filereadable(path) && (path !~# '^[A-Z]:')
				let path = expand(fnamemodify(path, ':h') .. '/' .. m[1])
			endif
			return qfjob#match(path, m[2], m[3], m[4])
		else
			return qfjob#do_not_match(a:line)
		endif
	endfunction
endif
