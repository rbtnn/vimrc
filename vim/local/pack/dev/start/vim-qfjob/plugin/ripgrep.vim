
let g:loaded_ripgrep = 1

if executable('rg')
	command! -nargs=* RipGrep :call RipGrep(<q-args>)

	function! RipGrep(q_args) abort
		let cmd = ['rg', '--vimgrep', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : ['.'])
		call qfjob#start('ripgrep', cmd, function('s:line_parser'))
	endfunction

	function s:line_parser(line) abort
		let m = matchlist(a:line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
		if !empty(m)
			let path = m[1]
			if !filereadable(path) && (path !~# '^[A-Z]:')
				let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
			endif
			return qfjob#match(path, m[2], m[3], m[4])
		else
			return qfjob#do_not_match(a:line)
		endif
	endfunction
endif

