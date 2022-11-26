
let g:ff_sources = get(g:, 'ff_sources', ['mrw', 'buffer', 'script', 'ls-files'])

let s:cachedrootdir = ''
let s:cachedlines = []
let s:maxlength = 0

function! ff#main(q_bang) abort
	let rootdir = git#utils#get_rootdir('.', 'git')

	if ('!' == a:q_bang) || (s:cachedrootdir != rootdir) || empty(s:cachedlines)
		let lines = []

		if -1 != index(g:ff_sources, 'mrw')
			if exists('g:loaded_mrw')
				for path in map(mrw#read_cachefile(), { i,x -> x['path'] })
					call s:extend_line(lines, path)
				endfor
			endif
		endif

		if -1 != index(g:ff_sources, 'buffer')
			for path in map(getbufinfo(), { i,x -> x['name'] })
				call s:extend_line(lines, path)
			endfor
		endif

		if -1 != index(g:ff_sources, 'script')
			for path in map(getscriptinfo(), { i,x -> x['name'] })
				call s:extend_line(lines, path)
			endfor
		endif

		if -1 != index(g:ff_sources, 'ls-files')
			if isdirectory(rootdir) && executable('git')
				for path in map(git#utils#system('git --no-pager ls-files', rootdir), { i,x -> rootdir .. '/' .. x })
					call s:extend_line(lines, path)
				endfor
			endif
		endif

		let s:maxlength = 0
		for path in lines
			let fname = fnamemodify(path, ':t')
			if s:maxlength < len(fname)
				let s:maxlength = len(fname)
			endif
		endfor
		let s:maxlength += 1
		let s:cachedrootdir = rootdir
		let s:cachedlines = lines
	endif

	let winid = popup_menu([], git#utils#get_popupwin_options())
	if -1 != winid
		call win_execute(winid, 'call clearmatches()')
		call win_execute(winid, 'call matchadd("SpecialKey", "\\[.\\+\\]$")')
		call s:set_title(winid, '')
		call s:update_lines(winid)
		call popup_setoptions(winid, {
			\ 'filter': function('ff#popup_filter', [rootdir]),
			\ 'callback': function('ff#popup_callback'),
			\ })
	endif
endfunction

function! s:extend_line(lines, path) abort
	let path = fnamemodify(a:path, ':p:gs!\\!/!')
	if -1 == index(a:lines, path)
		if filereadable(path)
			call extend(a:lines, [path])
		endif
	endif
endfunction

function! s:update_lines(winid) abort
	let bnr = winbufnr(a:winid)
	let title = s:get_title(a:winid)
	let lnum = 0
	silent! call deletebufline(bnr, 1, '$')
	for path in s:cachedlines
		try
			let fname = fnamemodify(path, ':t')
			let dir = fnamemodify(path, ':h')
			if empty(title) || (fname =~ title)
				let lnum += 1
				call setbufline(bnr, lnum, printf('%-' .. s:maxlength .. 's[%s]', fname, dir))
			endif
		catch
		endtry
	endfor
endfunction

function! s:set_title(winid, text) abort
	let opts = git#utils#get_popupwin_options()
	call popup_setoptions(a:winid, {
		\ 'title': (empty(a:text) ? '' : ' ' .. a:text .. ' '),
		\ })
endfunction

function! s:get_title(winid) abort
	return trim(get(popup_getoptions(a:winid), 'title', ''))
endfunction

function! ff#popup_filter(rootdir, winid, key) abort
	let xs = split(s:get_title(a:winid), '\zs')
	let lnum = line('.', a:winid)
	if 21 == char2nr(a:key)
		" Ctrl-u
		if 0 < len(xs)
			call remove(xs, 0, -1)
			call s:set_title(a:winid, join(xs, ''))
			call s:update_lines(a:winid)
		endif
		return 1
	elseif (10 == char2nr(a:key)) || (14 == char2nr(a:key))
		" Ctrl-n or Ctrl-j
		if lnum == line('$', a:winid)
			call git#utils#set_cursorline(a:winid, 1)
		else
			call git#utils#set_cursorline(a:winid, lnum + 1)
		endif
		return 1
	elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key))
		" Ctrl-p or Ctrl-k
		if lnum == 1
			call git#utils#set_cursorline(a:winid, line('$', a:winid))
		else
			call git#utils#set_cursorline(a:winid, lnum - 1)
		endif
		return 1
	elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
		" Ctrl-h or bs
		if 0 < len(xs)
			call remove(xs, -1)
			call s:set_title(a:winid, join(xs, ''))
			call s:update_lines(a:winid)
		endif
		return 1
	elseif 0x20 == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")
	elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
		let xs += [a:key]
		call s:set_title(a:winid, join(xs, ''))
		call s:update_lines(a:winid)
		return 1
	elseif 0x0d == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")
	elseif char2nr(a:key) < 0x20
		return popup_filter_menu(a:winid, "\<esc>")
	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! ff#popup_callback(winid, result) abort
	if -1 != a:result
		let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
		let m = matchlist(line, '^\(.\+\)\[\(.\+\)\]$')
		if !empty(m)
			let path = expand(m[2] .. '/' .. trim(m[1]))
			if filereadable(path)
				call git#utils#open_file(path, -1)
			endif
		endif
	endif
endfunction

