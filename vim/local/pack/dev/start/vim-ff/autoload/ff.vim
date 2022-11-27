
let g:ff_sources = get(g:, 'ff_sources', ['mrw', 'buffer', 'script', 'ls-files'])

let s:ctx = get(s:, 'ctx', {})

function! ff#main(q_bang) abort
	let rootdir = git#utils#get_rootdir('.', 'git')

	if ('!' == a:q_bang) || (get(s:ctx, 'rootdir', '') != rootdir) || empty(s:ctx)
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

		let s:ctx = {
			\ 'rootdir': rootdir,
			\ 'lines': lines,
			\ 'query': '',
			\ }
	endif

	let winid = popup_menu([], git#utils#get_popupwin_options())
	if -1 != winid
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
	let lnum = 0
	let xs = []
	let maxlen = 0
	try
		silent! call deletebufline(bnr, 1, '$')

		for path in s:ctx['lines']
			let fname = fnamemodify(path, ':t')
			let dir = fnamemodify(path, ':h')
			if empty(s:ctx['query']) || (fname =~ s:ctx['query'])
				let xs += [[fname, dir]]
				if maxlen < len(fname)
					let maxlen = len(fname)
				endif
			endif
		endfor

		for x in xs
			let lnum += 1
			call setbufline(bnr, lnum, printf('%-' .. maxlen .. 's [%s]', x[0], x[1]))
		endfor
	catch
		echohl Error
		echo v:exception
		echohl None
	endtry

	call win_execute(a:winid, 'call clearmatches()')
	call win_execute(a:winid, 'call matchadd("SpecialKey", "\\[.\\+\\]$")')
	if !empty(s:ctx['query'])
		try
			call win_execute(a:winid, 'call matchadd("Constant", "\\c" .. ' .. string(s:ctx['query']) .. ' .. "\\%<' .. maxlen .. 'v")')
		catch
		endtry
	endif

	call popup_setoptions(a:winid, {
		\ 'title': printf(' [%d/%d] %s ', lnum, len(s:ctx['lines']), (empty(s:ctx['query']) ? '' : '/' .. s:ctx['query'] .. '/')),
		\ })

	call git#utils#set_cursorline(a:winid, 1)
endfunction

function! ff#popup_filter(rootdir, winid, key) abort
	let xs = split(s:ctx['query'], '\zs')
	let lnum = line('.', a:winid)
	if 21 == char2nr(a:key)
		" Ctrl-u
		if 0 < len(xs)
			call remove(xs, 0, -1)
			let s:ctx['query'] = join(xs, '')
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
			let s:ctx['query'] = join(xs, '')
			call s:update_lines(a:winid)
		endif
		return 1
	elseif 0x20 == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")
	elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
		let xs += [a:key]
		let s:ctx['query'] = join(xs, '')
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

