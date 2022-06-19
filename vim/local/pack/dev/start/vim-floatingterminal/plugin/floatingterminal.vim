
let g:loaded_floatingterminal = 1

if !has('nvim')
	let s:cmd = [&shell]

	command! -nargs=0 FloatingTerminalToggle :call s:toggle_floatingterminal()

	function! s:toggle_floatingterminal() abort
		let exists_term = v:false
		for winid in popup_list()
			let x = get(getwininfo(winid), 0, { 'terminal' : v:false })
			if x['terminal'] && (term_getstatus(x['bufnr']) != 'finished')
				call popup_close(winid)
				let exists_term = v:true
			endif
		endfor
		if !exists_term
			let bnr = get(filter(term_list(), { _,x -> term_getstatus(x) != 'finished' }), 0, -1)
			if -1 == bnr
				let bnr = term_start(s:cmd, {
					\   'hidden': 1,
					\   'term_kill': 'kill',
					\   'term_finish': 'close',
					\ })
			endif
			call popup_create(bnr, git#utils#get_popupwin_options())
		endif
	endfunction

	if has('win32') && executable('wmic')
		function! s:out_cb(ch, mes) abort
			if 14393 < str2nr(trim(a:mes))
				let s:cmd = [&shell, '/K', 'doskey pwd=cd & doskey ls=dir /b & prompt $e[96m$P$G$e[0m']
			endif
		endfunction
		call job_start('wmic os get BuildNumber', { 'out_cb': function('s:out_cb'), })
	endif
endif
