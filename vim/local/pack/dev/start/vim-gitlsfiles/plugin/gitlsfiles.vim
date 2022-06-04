
let g:loaded_gitlsfiles = 1

if !has('nvim') && executable('git')
	command! -bang -nargs=0 GitLsFiles :call s:main(<q-bang>) 

	function! s:main(q_bang) abort
		let rootdir = s:get_rootdir('.', 'git')
		if isdirectory(rootdir)
			let width = &columns - 2
			let height = &lines - &cmdheight - 4
			if has('tabsidebar')
				if ((&showtabsidebar == 1) && (1 < tabpagenr('$'))) || (&showtabsidebar == 2)
					let width -= &tabsidebarcolumns
				endif
			endif
			let winid = popup_menu([], {
				\ 'filter': function('s:popup_filter', [rootdir]),
				\ 'callback': function('s:popup_callback', [rootdir]),
				\ 'scrollbar': 0,
				\ 'pos': 'topleft',
				\ 'line': 1,
				\ 'col': 1,
				\ 'minheight': height,
				\ 'maxheight': height,
				\ 'minwidth': width,
				\ 'maxwidth': width,
				\ 'wrap': 1,
				\ 'border': [0, 0, 0, 0],
				\ 'padding': [2, 1, 1, 1],
				\ })
			call s:update_window_async(rootdir, winid, [])
		else
			echohl Error
			echo '[gitlsfiles] The directory is not under git control!'
			echohl None
		endif
	endfunction

	function! s:get_rootdir(path, cmdname) abort
		let xs = split(fnamemodify(a:path, ':p'), '[\/]')
		let prefix = (has('mac') || has('linux')) ? '/' : ''
		while !empty(xs)
			let path = prefix .. join(xs + ['.' .. a:cmdname], '/')
			if isdirectory(path) || filereadable(path)
				return prefix .. join(xs, '/')
			endif
			call remove(xs, -1)
		endwhile
		return ''
	endfunction

	function! s:popup_filter(rootdir, winid, key) abort
		let xs = split(trim(get(popup_getoptions(a:winid), 'title', '')), '\zs')
		let lnum = line('.', a:winid)
		if 21 == char2nr(a:key)
			" Ctrl-u
			if 0 < len(xs)
				call remove(xs, 0, -1)
				call s:update_window_async(a:rootdir, a:winid, xs)
			endif
			return 1
		elseif 14 == char2nr(a:key)
			" Ctrl-n
			if lnum == line('$', a:winid)
				call s:set_cursorline(a:winid, 1)
			else
				call s:set_cursorline(a:winid, lnum + 1)
			endif
			return 1
		elseif 16 == char2nr(a:key)
			" Ctrl-p
			if lnum == 1
				call s:set_cursorline(a:winid, line('$', a:winid))
			else
				call s:set_cursorline(a:winid, lnum - 1)
			endif
			return 1
		elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
			" Ctrl-h or bs
			if 0 < len(xs)
				call remove(xs, -1)
				call s:update_window_async(a:rootdir, a:winid, xs)
			endif
			return 1
		elseif (0x20 == char2nr(a:key)) && (0 == len(xs))
			return 1
		elseif (0x20 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
			let xs += [a:key]
			call s:update_window_async(a:rootdir, a:winid, xs)
			return 1
		else
			return popup_filter_menu(a:winid, a:key)
		endif
	endfunction

	function! s:popup_callback(rootdir, winid, result) abort
		let line = a:rootdir .. '/' .. trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
		if filereadable(line)
			let bnr = s:strict_bufnr(line)
			if -1 == bnr
				execute printf('edit %s', fnameescape(line))
			else
				execute printf('buffer %d', bnr)
			endif
		endif
	endfunction

	function! s:update_window_async(rootdir, winid, xs) abort
		if exists('s:job')
			call job_stop(s:job)
			unlet s:job
		endif
		let bnr = winbufnr(a:winid)
		let text = join(a:xs, '')
		call popup_setoptions(a:winid, {
			\ 'title': ' ' .. text .. ' ',
			\ })
		silent! call deletebufline(bnr, 1, '$')
		if !empty(text)
			let cmd = ['git', 'ls-files', '*' .. text .. '*']
			let s:job = job_start(cmd, {
				\ 'callback': function('s:job_callback', [bnr, a:winid]),
				\ 'cwd': a:rootdir,
				\ })
		endif
	endfunction

	function! s:job_callback(bnr, winid, ch, msg) abort
		let lnum = line('$', a:winid)
		if empty(getbufline(a:bnr, lnum)[0])
			call setbufline(a:bnr, lnum, a:msg)
		else
			call appendbufline(a:bnr, lnum, a:msg)
		endif
	endfunction

	function! s:set_cursorline(winid, lnum) abort
		call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
	endfunction

	function! s:strict_bufnr(path) abort
		let bnr = bufnr(a:path)
		let fname1 = fnamemodify(a:path, ':t')
		let fname2 = fnamemodify(bufname(bnr), ':t')
		if (-1 == bnr) || (fname1 != fname2)
			return -1
		else
			return bnr
		endif
	endfunction
endif
