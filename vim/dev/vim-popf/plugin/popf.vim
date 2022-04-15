
let g:loaded_popf = 1

if !has('nvim')
	command! -bang -nargs=0 Popf :call <SID>main(<q-bang>) 

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

	function! s:update_window(data, winid, xs) abort
		let bnr = winbufnr(a:winid)
		call setbufline(bnr, 1, join(a:xs, ''))
		call setbufline(bnr, s:MIN_LNUM, '')
		call deletebufline(bnr, s:MIN_LNUM + 1, s:MAX_LNUM)
		let n = s:MIN_LNUM
		let pattern = trim(join(a:xs[1:], ''))
		try
			call win_execute(a:winid, 'call clearmatches()')
			for x in a:data
				if empty(pattern) || (x['path'] =~ pattern)
					if has_key(x, 'lnum') && has_key(x, 'col')
						call setbufline(bnr, n, printf('%s(%d,%d)', x['path'], x['lnum'], x['col']))
					else
						call setbufline(bnr, n, x['path'])
					endif
					let n += 1
					if s:MAX_LNUM < n
						break
					endif
				endif
			endfor
			if !empty(pattern)
				call win_execute(a:winid, printf('call matchadd("Search", %s)', string((&ignorecase ? '\c' : '') .. '\%>1l' .. pattern)))
			endif
		catch
			call setbufline(bnr, n, v:exception)
		endtry
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

	function! s:callback(winid, result) abort
		let line = get(getbufline(winbufnr(a:winid), a:result), 0, '')
		if !empty(line)
			let m = matchlist(s:fix_path(trim(line)), '^\(.\{-\}\)\%((\(\d\+\),\(\d\+\))\)\?$')
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

	function! s:fix_path(path) abort
		return fnamemodify(resolve(a:path), ':p:gs?\\?/?')
	endfunction

	function! s:pre_source() abort
		let xs = []
		for x in get(g:, 'popf_globlist', [])
			let xs += map(split(glob(x), "\n"), { i,x -> { 'path': x } })
		endfor
		let s:globlist = xs
	endfunction

	function! s:source() abort
		let xs = []
		silent! runtime autoload/mrw.vim
		if exists('g:mrw_cache_path')
			if filereadable(g:mrw_cache_path)
				let lines = readfile(g:mrw_cache_path, '', g:mrw_limit)
				for i in range(0, len(lines) - 1)
					let xs += [json_decode(lines[i])]
				endfor
			endif
		endif
		if exists('s:globlist')
			let xs += s:globlist
		endif
		return xs
	endfunction

	function! s:main(q_bang) abort
		let s:MIN_LNUM = 2
		let s:MAX_LNUM = &lines / 4

		if a:q_bang == '!'
			call s:pre_source()
		endif
		let data = s:source()

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
			\ 'cursorline': v:true,
			\ 'minheight': s:MIN_LNUM,
			\ 'maxheight': s:MAX_LNUM,
			\ 'minwidth': width,
			\ 'maxwidth': width,
			\ 'highlight': 'Normal',
			\ 'border': [1, 1, 1, 1],
			\ })
		call s:update_window(data, winid, ['>'])
		call s:set_cursorline(winid, s:MIN_LNUM)
		call win_execute(winid, 'setfiletype popf')
	endfunction

	augroup popf
		autocmd!
		autocmd VimEnter * :call s:pre_source()
	augroup END
endif

