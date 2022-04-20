
function! popf#exec(q_bang) abort
	let s:MIN_LNUM = 2
	let s:MAX_LNUM = &lines / 4

	let width = &columns - 4
	if has('tabsidebar')
		if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
			let width -= &tabsidebarcolumns
		endif
	endif

	let winid = popup_menu([], {
		\ 'filter': function('s:filter'),
		\ 'callback': function('s:callback'),
		\ 'pos': 'topleft',
		\ 'line': 1,
		\ 'col': 1,
		\ 'minheight': s:MIN_LNUM,
		\ 'maxheight': s:MAX_LNUM,
		\ 'minwidth': width,
		\ 'maxwidth': width,
		\ 'highlight': 'Normal',
		\ 'border': [1, 1, 1, 1],
		\ })

	call s:update_window_async(winid, ['>'])
	call win_execute(winid, 'setfiletype popf')
endfunction

function! s:filter(winid, key) abort
	let xs = split(get(getbufline(winbufnr(a:winid), 1), 0, ''), '\zs')
	let lnum = line('.', a:winid)
	if 21 == char2nr(a:key)
		" Ctrl-u
		if 1 < len(xs)
			call remove(xs, 1, -1)
			call s:update_window_async(a:winid, xs)
		endif
		return 1
	elseif 14 == char2nr(a:key)
		" Ctrl-n
		if lnum == line('$', a:winid)
			call s:set_cursorline(a:winid, s:MIN_LNUM)
		else
			call s:set_cursorline(a:winid, lnum + 1)
		endif
		return 1
	elseif 16 == char2nr(a:key)
		" Ctrl-p
		if lnum == s:MIN_LNUM
			call s:set_cursorline(a:winid, line('$', a:winid))
		else
			call s:set_cursorline(a:winid, lnum - 1)
		endif
		return 1
	elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
		" Ctrl-h or bs
		if 1 < len(xs)
			call remove(xs, -1)
			call s:update_window_async(a:winid, xs)
		endif
		return 1
	elseif (0x20 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
		let xs += [a:key]
		call s:update_window_async(a:winid, xs)
		return 1
	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! s:callback(winid, result) abort
	let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
	if filereadable(line)
		let bnr = s:strict_bufnr(line)
		if -1 == bnr
			execute printf('edit %s', fnameescape(line))
		else
			execute printf('buffer %d', bnr)
		endif
	endif
endfunction

function! s:update_window_async(winid, xs) abort
	if exists('s:timer')
		call timer_stop(s:timer)
		unlet s:timer
	endif
	let bnr = winbufnr(a:winid)
	call setbufline(bnr, 1, join(a:xs, ''))
	call deletebufline(bnr, s:MIN_LNUM, s:MAX_LNUM)
	let s:timer = timer_start(0, function('s:update_window', [a:winid, a:xs]))
endfunction

function! s:readdir(maxdepth, winid, bnr, pattern, file_count, path) abort
	let file_count = a:file_count
	if 0 < a:maxdepth
		let dirs = []
		silent! let xs = readdir(a:path, 1, { 'sort': 'none' })
		for x in xs
			if !(line('$', a:winid) < s:MAX_LNUM)
				break
			endif
			let path = expand(a:path .. '/' .. x)
			if isdirectory(path)
				if (-1 == index(['undofiles', 'AppData', 'node_modules'], x)) && (x[0] != '.')
					let dirs += [path]
				endif
			else
				let file_count += 1
				if path =~ a:pattern
					call setbufline(a:bnr, line('$', a:winid) + 1, path)
				endif
			endif
		endfor
		if line('$', a:winid) < s:MAX_LNUM
			for path in dirs
				let file_count = s:readdir(a:maxdepth - 1, a:winid, a:bnr, a:pattern, file_count, path)
			endfor
		endif
	endif
	call popup_setoptions(a:winid, { 'title': printf(' %d/%d ', line('$', a:winid) - 1, file_count) })
	return file_count
endfunction

function! s:update_window(winid, xs, t) abort
	let bnr = winbufnr(a:winid)
	let n = 0
	let pattern = trim(join(a:xs[1:], ''))
	try
		let n = s:readdir(10, a:winid, bnr, pattern, s:MIN_LNUM, '.')
		call deletebufline(bnr, n, s:MAX_LNUM)
	catch
		call setbufline(bnr, s:MIN_LNUM, v:exception)
	endtry
	if n == 0
		call popup_setoptions(a:winid, { 'cursorline': v:false })
	else
		call popup_setoptions(a:winid, { 'cursorline': v:true })
		if 1 == line('.', a:winid)
			call s:set_cursorline(a:winid, s:MIN_LNUM)
		endif
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

