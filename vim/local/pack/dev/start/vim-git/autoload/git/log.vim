
let s:last_lnum = 1
let s:last_cmd = ''
let s:last_rootdir = ''

function! git#log#main(q_args) abort
	let cmd = 'git --no-pager log --numstat --date=iso -50'
	let rootdir = git#utils#get_rootdir('.', 'git')
	if !isdirectory(rootdir)
		echo 'The directory is not under git control!'
	else
		let winid = popup_menu([], git#utils#get_popupwin_options())
		if -1 != winid
			call popup_setoptions(winid, {
				\ 'filter': function('git#log#popup_filter', [rootdir]),
				\ 'callback': function('git#log#popup_callback', [rootdir]),
				\ })
			let lines = s:build_lines(cmd, rootdir)
			call popup_settext(winid, lines)
			if (s:last_cmd == cmd) && (s:last_rootdir == rootdir)
				call git#utils#set_cursorline(winid, s:last_lnum)
			else
				let s:last_lnum = 1
				let s:last_cmd = cmd
				let s:last_rootdir = rootdir
			endif
		endif
	endif
endfunction

function! git#log#popup_filter(rootdir, winid, key) abort
	let lnum = line('.', a:winid)

	if (10 == char2nr(a:key)) || (14 == char2nr(a:key)) || (106 == char2nr(a:key))
		" Ctrl-n or Ctrl-j or j
		if lnum == line('$', a:winid)
			call git#utils#set_cursorline(a:winid, 1)
		else
			call git#utils#set_cursorline(a:winid, lnum + 1)
		endif
		let s:last_lnum = line('.', a:winid)
		return 1

	elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key)) || (107 == char2nr(a:key))
		" Ctrl-p or Ctrl-k or k
		if lnum == 1
			call git#utils#set_cursorline(a:winid, line('$', a:winid))
		else
			call git#utils#set_cursorline(a:winid, lnum - 1)
		endif
		let s:last_lnum = line('.', a:winid)
		return 1

	elseif 100 == char2nr(a:key)
		" d
		call s:show_log(a:rootdir, a:winid, line('.', a:winid), v:true)
		return 1

	elseif 71 == char2nr(a:key)
		" G
		call git#utils#set_cursorline(a:winid, line('$', a:winid))
		let s:last_lnum = line('.', a:winid)
		return 1

	elseif 103 == char2nr(a:key)
		" g
		call git#utils#set_cursorline(a:winid, 1)
		let s:last_lnum = line('.', a:winid)
		return 1

	elseif 0x0d == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")

	elseif char2nr(a:key) < 0x20
		return popup_filter_menu(a:winid, "\<esc>")

	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! s:show_log(rootdir, winid, lnum, stay) abort
	let line = get(getbufline(winbufnr(a:winid), a:lnum), 0, '')
	if !empty(line)
		let hash = matchstr(line, '^[0-9a-f]\+\ze\s')
		let cmd = 'git --no-pager diff -w ' .. printf('%s~1..%s', hash, hash)
		call git#utils#open_diffwindow(a:rootdir, cmd, v:false)
		if a:stay
			wincmd w
		endif
		call popup_setoptions(a:winid, git#utils#get_popupwin_options())
	endif
endfunction

function! git#log#popup_callback(rootdir, winid, result) abort
	if -1 != a:result
		call s:show_log(a:rootdir, a:winid, s:last_lnum, v:false)
	endif
endfunction

function! s:logfmt(commit, date, add, del, msg, merge) abort
	return printf('%s %s %12s %s', a:commit, a:date, a:merge ? '' : printf('(+%d,-%d)', a:add, a:del), a:msg)
endfunction

function! s:build_lines(cmd, rootdir) abort
	let lines = git#utils#system(a:cmd, a:rootdir)
	let new_lines = []
	let commit = ''
	let date = ''
	let add = 0
	let del = 0
	let msg = ''
	let merge = v:false
	for line in lines
		if line =~# '^commit [a-f0-9]\+$'
			if !empty(commit)
				let new_lines += [s:logfmt(commit, date, add, del, msg, merge)]
			endif
			let commit = matchstr(line, '^commit \zs[a-f0-9]\+$')[:7]
			let date = ''
			let add = 0
			let del = 0
			let msg = ''
			let merge = v:false
		elseif line =~# '^Author:\s\+'
		elseif line =~# '^Merge:\s\+'
			let merge = v:true
		elseif line =~# '^Date:\s\+'
			let date = matchstr(line, '^Date:\s\+\zs.*$')[:-7]
		elseif line =~# '^    .\+$'
			let msg = line[4:]
		elseif line =~# '^\d\+\t\d\+.\+$'
			let xs = split(line, '\t')
			let add += str2nr(xs[0])
			let del += str2nr(xs[1])
		endif
	endfor
	if !empty(commit)
		let new_lines += [s:logfmt(commit, date, add, del, msg, merge)]
	endif
	return new_lines
endfunction

