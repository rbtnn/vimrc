
function! popf#exec(q_bang) abort
	let s:MIN_LNUM = 2
	let s:MAX_LNUM = &lines / 4

	if a:q_bang == '!'
		call popf#pre_source()
	endif
	let data = []
	silent! let data += mrw#read_cachefile()
	if exists('s:globlist')
		let data += s:globlist
	endif

	" exclude the current buffer.
	let curr_path = expand('%:p:gs?\\?/?')
	if filereadable(curr_path)
		call filter(data, { i,x -> x['path'] != curr_path })
	endif

	let width = &columns - 4
	if has('tabsidebar')
		if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
			let width -= &tabsidebarcolumns
		endif
	endif

	let winid = popup_menu([], {
		\ 'filter': function('s:filter', [data]),
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

	call s:update_window(data, winid, ['>'])
	call win_execute(winid, 'setfiletype popf')
endfunction

function! popf#pre_source() abort
	let xs = []
	for x in get(g:, 'popf_globlist', [])
		let xs += map(split(glob(x), "\n"), { i,x -> { 'path': fnamemodify(resolve(x), ':p:gs?\\?/?') } })
	endfor
	let s:globlist = xs
endfunction

function! s:filter(data, winid, key) abort
	let xs = split(get(getbufline(winbufnr(a:winid), 1), 0, ''), '\zs')
	let lnum = line('.', a:winid)
	if 21 == char2nr(a:key)
		" Ctrl-u
		if 1 < len(xs)
			call remove(xs, 1, -1)
			call s:update_window(a:data, a:winid, xs)
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
	elseif (128 == char2nr(a:key)) || (8 == char2nr(a:key))
		" Ctrl-h or bs
		if 1 < len(xs)
			call remove(xs, -1)
			call s:update_window(a:data, a:winid, xs)
		endif
		return 1
	elseif (0x20 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
		let xs += [a:key]
		call s:update_window(a:data, a:winid, xs)
		return 1
	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! s:callback(winid, result) abort
	let line = get(getbufline(winbufnr(a:winid), a:result), 0, '')
	if !empty(line)
		let m = matchlist(trim(line), '^\(.\{-\}\)\%((\(\d\+\),\(\d\+\))\)\?$')
		if !empty(m) && filereadable(m[1])
			let bnr = s:strict_bufnr(m[1])
			if -1 == bnr
				execute printf('edit %s', fnameescape(m[1]))
			else
				execute printf('buffer %d', bnr)
			endif
			if !empty(m[2]) && !empty(m[3])
				call cursor(str2nr(m[2]), str2nr(m[3]))
			endif
		endif
	endif
endfunction

function! s:update_window(data, winid, xs) abort
	let bnr = winbufnr(a:winid)
	call setbufline(bnr, 1, join(a:xs, ''))
	let n = 0
	let pattern = trim(join(a:xs[1:], ''))
	try
		call win_execute(a:winid, 'call clearmatches()')
		let pathes = []
		for x in a:data
			let path = get(x, 'path', '')
			let lnum = get(x, 'lnum', -1)
			let col = get(x, 'col', -1)
			if !filereadable(path)
				continue
			endif
			if !empty(pattern) && (path !~ pattern)
				continue
			endif
			if -1 != index(pathes, path)
				continue
			endif
			call setbufline(bnr, n + s:MIN_LNUM, 
				\ ((-1 != lnum) && (-1 != col))
				\ ? printf('%s(%d,%d)', path, lnum, col)
				\ : path
				\ )
			let pathes += [path]
			let n += 1
			if s:MAX_LNUM - s:MIN_LNUM < n
				break
			endif
		endfor
		if !empty(pattern)
			call win_execute(a:winid, printf('call matchadd("Search", %s)', string((&ignorecase ? '\c' : '') .. '\%>1l' .. pattern)))
		endif
	catch
		call setbufline(bnr, s:MIN_LNUM, v:exception)
	endtry
	call deletebufline(bnr, s:MIN_LNUM + n, s:MAX_LNUM)
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

