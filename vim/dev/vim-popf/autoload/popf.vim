
function! s:init() abort
	let s:PROMPT_STR = split(getcwd() .. '>', '\zs')
	let s:PROMPT_LEN = len(s:PROMPT_STR)
	let s:PROMPT_LNUM = 1
	let s:START_LNUM = 2
	let s:MAX_LNUM = &lines / 4
	let s:MAX_DEPTH = get(g:, 'popf_max_depth', 10)
	let s:IGNORE_DIRNAMES = get(g:, 'popf_ignore_dirnames', [
		\ 'undofiles', 'AppData', 'node_modules', 'bin',
		\ ])
	let s:IGNORE_EXTS = map(get(g:, 'popf_ignore_exts', [
		\ 'dll', 'exe', 'obj', 'o', 'obj', 'dat', 'zip', 'png', 'jpg', 'ico',
		\ 'mp3', 'mp4', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'gif', 'wav',
		\ 'jpeg', 'msi', 'bin',
		\ ]), { _,x -> tolower(x) })
endfunction

function! popf#exec(q_bang) abort
	call s:init()

	let width = &columns
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
		\ 'minheight': s:PROMPT_LNUM,
		\ 'maxheight': s:MAX_LNUM,
		\ 'minwidth': width,
		\ 'maxwidth': width,
		\ 'border': [0, 0, 0, 0],
		\ 'padding': [0, 0, 0, 0],
		\ })

	call s:update_window_async(winid, s:PROMPT_STR)
	call win_execute(winid, 'setfiletype popf')
endfunction

function! s:filter(winid, key) abort
	let xs = split(get(getbufline(winbufnr(a:winid), 1), 0, ''), '\zs')
	let lnum = line('.', a:winid)
	if 21 == char2nr(a:key)
		" Ctrl-u
		if s:PROMPT_LEN < len(xs)
			call remove(xs, s:PROMPT_LEN, -1)
			call s:update_window_async(a:winid, xs)
		endif
		return 1
	elseif 14 == char2nr(a:key)
		" Ctrl-n
		if lnum == line('$', a:winid)
			call s:set_cursorline(a:winid, s:START_LNUM)
		else
			call s:set_cursorline(a:winid, lnum + 1)
		endif
		return 1
	elseif 16 == char2nr(a:key)
		" Ctrl-p
		if lnum == s:START_LNUM
			call s:set_cursorline(a:winid, line('$', a:winid))
		else
			call s:set_cursorline(a:winid, lnum - 1)
		endif
		return 1
	elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
		" Ctrl-h or bs
		if s:PROMPT_LEN < len(xs)
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
	call setbufline(bnr, s:PROMPT_LNUM, join(a:xs, ''))
	call deletebufline(bnr, s:START_LNUM, s:MAX_LNUM)
	let s:timer = timer_start(0, function('s:update_window', [a:winid, a:xs]))
endfunction

function! s:readdir(depth, winid, bnr, pattern, path) abort
	if a:depth < s:MAX_DEPTH
		let dirs = []
		silent! let xs = readdir(a:path, 1, { 'sort': 'none' })
		for x in xs
			if !(line('$', a:winid) < s:MAX_LNUM)
				break
			endif
			let path = expand(a:path .. '/' .. x)
			if isdirectory(path)
				if (-1 == index(s:IGNORE_DIRNAMES, x)) && (x[0] != '.')
					let dirs += [path]
				endif
			else
				let fname = fnamemodify(path, ':t')
				let ext = tolower(fnamemodify(path, ':e'))
				if (path =~ a:pattern)
					\ && (-1 == index(s:IGNORE_EXTS, ext))
					\ && (fname != 'desktop.ini')
					\ && (fname !~ '^ntuser\.')
					call setbufline(a:bnr, line('$', a:winid) + 1, path)
					call win_execute(a:winid, 'redraw')
				endif
			endif
		endfor
		if line('$', a:winid) < s:MAX_LNUM
			for path in dirs
				call s:readdir(a:depth + 1, a:winid, a:bnr, a:pattern, path)
			endfor
		endif
	endif
endfunction

function! s:update_window(winid, xs, t) abort
	let bnr = winbufnr(a:winid)
	let pattern = join(a:xs[(s:PROMPT_LEN):], '')
	call popup_setoptions(a:winid, { 'cursorline': v:false })
	if !empty(pattern)
		try
			call s:readdir(0, a:winid, bnr, pattern, '.')
		catch
			call setbufline(bnr, s:START_LNUM, v:exception)
		endtry
		if s:PROMPT_LNUM != line('$', a:winid)
			call popup_setoptions(a:winid, { 'cursorline': v:true })
			if s:PROMPT_LNUM == line('.', a:winid)
				call s:set_cursorline(a:winid, s:START_LNUM)
			endif
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

