
function! git#lsfiles#main(q_bang) abort
	let rootdir = git#utils#get_rootdir('.', 'git')
	let winid = git#utils#create_popupwin(rootdir, [])
	if -1 != winid
		call popup_setoptions(winid, {
			\ 'filter': function('git#lsfiles#popup_filter', [rootdir]),
			\ 'callback': function('git#lsfiles#popup_callback', [rootdir]),
			\ })
		call s:set_title(winid, '')
		call s:update_window_async(rootdir, winid)
	endif
endfunction

function! git#lsfiles#popup_filter(rootdir, winid, key) abort
	let xs = split(s:get_title(a:winid), '\zs')
	let lnum = line('.', a:winid)
	if 21 == char2nr(a:key)
		" Ctrl-u
		if 0 < len(xs)
			call remove(xs, 0, -1)
			call s:set_title(a:winid, join(xs, ''))
			call s:update_window_async(a:rootdir, a:winid)
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
			call s:update_window_async(a:rootdir, a:winid)
		endif
		return 1
	elseif 0x20 == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")
	elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
		let xs += [a:key]
		call s:set_title(a:winid, join(xs, ''))
		call s:update_window_async(a:rootdir, a:winid)
		return 1
	elseif 0x0d == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")
	elseif char2nr(a:key) < 0x20
		return popup_filter_menu(a:winid, "\<esc>")
	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! git#lsfiles#popup_callback(rootdir, winid, result) abort
	if -1 != a:result
		let line = get(getbufline(winbufnr(a:winid), a:result), 0, '')
		let path = a:rootdir .. '/' .. trim(line)
		if filereadable(path)
			call git#utils#open_file(path, -1)
		endif
	endif
endfunction



function! s:update_window_async(rootdir, winid) abort
	if exists('s:job')
		call job_stop(s:job)
		unlet s:job
	endif
	let bnr = winbufnr(a:winid)
	silent! call deletebufline(bnr, 1, '$')
	let s:job = job_start(['git', '--no-pager', 'ls-files'], {
		\ 'callback': function('s:job_callback', [bnr, a:winid]),
		\ 'cwd': a:rootdir,
		\ })
endfunction

function! s:job_callback(bnr, winid, ch, msg) abort
	try
		let title = s:get_title(a:winid)
		if empty(title) || (a:msg =~ title)
			let lnum = line('$', a:winid)
			let line = getbufline(a:bnr, lnum)[0]
			if empty(line)
				call setbufline(a:bnr, lnum, a:msg)
			else
				call appendbufline(a:bnr, lnum, a:msg)
			endif
		endif
	catch
	endtry
endfunction

function! s:set_title(winid, text) abort
	call popup_setoptions(a:winid, {
		\ 'title': (empty(a:text) ? '' : ' ' .. a:text .. ' '),
		\ })
endfunction

function! s:get_title(winid) abort
	return trim(get(popup_getoptions(a:winid), 'title', ''))
endfunction

