
let g:ff_sources = get(g:, 'ff_sources', ['mrw', 'buffer', 'script', 'ls-files'])
let g:mrw_path = expand('~/.ffmrw')

function! ff#main(q_bang) abort
	let winid = popup_menu([], git#utils#get_popupwin_options())
	if -1 != winid
		let rootdir = git#utils#get_rootdir('.', 'git')

		call popup_setoptions(winid, {
			\ 'filter': function('s:popup_filter', [rootdir]),
			\ 'callback': function('s:popup_callback'),
			\ })

		let s:ctx = get(s:, 'ctx', {
			\ 'lines': [],
			\ 'lsfiles_caches': {},
			\ 'query': '',
			\ })

		let s:ctx['lines'] = []

		if -1 != index(g:ff_sources, 'mrw')
			for path in ff#read_mrwfile()
				call s:extend_line(s:ctx['lines'], path)
			endfor
		endif

		if -1 != index(g:ff_sources, 'buffer')
			for path in map(getbufinfo(), { i,x -> x['name'] })
				call s:extend_line(s:ctx['lines'], path)
			endfor
		endif

		if -1 != index(g:ff_sources, 'script')
			for path in map(getscriptinfo(), { i,x -> x['name'] })
				call s:extend_line(s:ctx['lines'], path)
			endfor
		endif

		if -1 != index(g:ff_sources, 'ls-files')
			if isdirectory(rootdir) && executable('git')
				if ('!' == a:q_bang) || !has_key(s:ctx['lsfiles_caches'], rootdir)
					if exists('s:job')
						call job_stop(s:job)
						unlet s:job
					endif
					let s:ctx['lsfiles_caches'][rootdir] = []
					let s:job = job_start(['git', '--no-pager', 'ls-files'], {
						\ 'callback': function('s:job_callback', [rootdir, winid, s:ctx['lsfiles_caches'][rootdir]]),
						\ 'cwd': rootdir,
						\ })
				endif
			endif
		endif

		call s:update_lines(rootdir, winid)
	endif
endfunction

function! ff#mrw_bufwritepost() abort
	let path = s:fix_path(g:mrw_path)
	let lines = ff#read_mrwfile()
	let fullpath = s:fix_path(expand('<afile>'))
	if fullpath != path
		let p = v:false
		if filereadable(path)
			if filereadable(fullpath)
				if 0 < len(get(lines, 0, ''))
					if fullpath != s:fix_path(get(lines, 0, ''))
						let p = v:true
					endif
				else
					let p = v:true
				endif
			endif
		else
			let p = v:true
		endif
		if p
			call writefile([fullpath] + filter(lines, { i,x -> x != fullpath }), path)
		endif
	endif
endfunction

function! ff#read_mrwfile() abort
	let path = s:fix_path(g:mrw_path)
	if filereadable(path)
		return readfile(path)
	else
		return []
	endif
endfunction

function! s:fix_path(path) abort
	return fnamemodify(resolve(a:path), ':p:gs?\\?/?')
endfunction

function! s:job_callback(rootdir, winid, lines, ch, msg) abort
	call s:extend_line(a:lines, a:rootdir .. '/' .. a:msg)
	call s:update_title(a:rootdir, a:winid)
endfunction

function! s:extend_line(lines, path) abort
	let path = s:fix_path(a:path)
	if -1 == index(a:lines, path)
		if filereadable(path)
			call extend(a:lines, [path])
		endif
	endif
endfunction

function! s:update_title(rootdir, winid) abort
	let n = line('$', a:winid)
	if empty(get(getbufline(winbufnr(a:winid), 1), 0, ''))
		let n = 0
	endif
	call popup_setoptions(a:winid, {
		\ 'title': printf(
		\    ' [%d/%d/%d] %s ',
		\    n,
		\    len(s:ctx['lines']),
		\    len(get(s:ctx['lsfiles_caches'], a:rootdir, [])),
		\    (empty(s:ctx['query']) ? '' : '/' .. s:ctx['query'] .. '/')
		\ ), })
endfunction

function! s:update_lines(rootdir, winid) abort
	let bnr = winbufnr(a:winid)
	let lnum = 0
	let xs = []
	let maxlen = 0
	let lines = []
	try
		silent! call deletebufline(bnr, 1, '$')
		for path in s:ctx['lines'] + get(s:ctx['lsfiles_caches'], a:rootdir, [])
			if -1 == index(lines, path)
				let lines += [path]
				let fname = fnamemodify(path, ':t')
				let dir = fnamemodify(path, ':h')
				if empty(s:ctx['query']) || (fname =~ s:ctx['query'])
					let xs += [[fname, dir]]
					if maxlen < len(fname)
						let maxlen = len(fname)
					endif
				endif
			endif
		endfor

		for x in xs
			let lnum += 1
			let d = strdisplaywidth(x[0]) - len(split(x[0], '\zs'))
			call setbufline(bnr, lnum, printf('%-' .. (maxlen + d) .. 's [%s]', x[0], x[1]))
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

	call s:update_title(a:rootdir, a:winid)
	call git#utils#set_cursorline(a:winid, 1)
endfunction

function! s:popup_filter(rootdir, winid, key) abort
	let xs = split(s:ctx['query'], '\zs')
	let lnum = line('.', a:winid)
	if 21 == char2nr(a:key)
		" Ctrl-u
		if 0 < len(xs)
			call remove(xs, 0, -1)
			let s:ctx['query'] = join(xs, '')
			call s:update_lines(a:rootdir, a:winid)
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
			call s:update_lines(a:rootdir, a:winid)
		endif
		return 1
	elseif 0x20 == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")
	elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
		let xs += [a:key]
		let s:ctx['query'] = join(xs, '')
		call s:update_lines(a:rootdir, a:winid)
		return 1
	elseif 0x0d == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")
	elseif char2nr(a:key) < 0x20
		return popup_filter_menu(a:winid, "\<esc>")
	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! s:popup_callback(winid, result) abort
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

