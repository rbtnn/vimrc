
let s:recently = get(s:, 'recently', {})

function! git#diff#recently() abort
	if empty(s:recently)
		echo 'You still haven''t used :GitDiff even once!'
	else
		let cmd = 'git --no-pager diff --numstat -w ' .. s:recently['q_args']
		let lines = git#utils#system(cmd, s:recently['rootdir'])
		if empty(lines)
			echo 'No modified files!'
		else
			let winid = popup_menu(lines, git#utils#get_popupwin_options())
			if -1 != winid
				call popup_setoptions(winid, {
					\ 'filter': function('git#diff#popup_filter', [s:recently['rootdir'], s:recently['q_args']]),
					\ 'callback': function('git#diff#popup_callback', [s:recently['rootdir'], s:recently['q_args']]),
					\ })
				call git#utils#set_cursorline(winid, s:recently['lnum'])
			endif
		endif
	endif
endfunction

function! git#diff#main(q_args) abort
	let rootdir = git#utils#get_rootdir('.', 'git')
	if !isdirectory(rootdir)
		echo 'The directory is not under git control!'
	else
		let s:recently = {
			\ 'lnum': 1,
			\ 'rootdir': rootdir,
			\ 'q_args': a:q_args,
			\ }
		call git#diff#recently()
	endif
endfunction

function! git#diff#popup_filter(rootdir, q_args, winid, key) abort
	let lnum = line('.', a:winid)

	if (10 == char2nr(a:key)) || (14 == char2nr(a:key)) || (106 == char2nr(a:key))
		" Ctrl-n or Ctrl-j or j
		if lnum == line('$', a:winid)
			call git#utils#set_cursorline(a:winid, 1)
		else
			call git#utils#set_cursorline(a:winid, lnum + 1)
		endif
		let s:recently['lnum'] = line('.', a:winid)
		return 1

	elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key)) || (107 == char2nr(a:key))
		" Ctrl-p or Ctrl-k or k
		if lnum == 1
			call git#utils#set_cursorline(a:winid, line('$', a:winid))
		else
			call git#utils#set_cursorline(a:winid, lnum - 1)
		endif
		let s:recently['lnum'] = line('.', a:winid)
		return 1

	elseif 100 == char2nr(a:key)
		" d
		call s:show_diff(a:rootdir, a:q_args, a:winid, line('.', a:winid), v:true)
		return 1

	elseif 71 == char2nr(a:key)
		" G
		call git#utils#set_cursorline(a:winid, line('$', a:winid))
		let s:recently['lnum'] = line('.', a:winid)
		return 1

	elseif 103 == char2nr(a:key)
		" g
		call git#utils#set_cursorline(a:winid, 1)
		let s:recently['lnum'] = line('.', a:winid)
		return 1

	elseif 0x0d == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")

	elseif char2nr(a:key) < 0x20
		return popup_filter_menu(a:winid, "\<esc>")

	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! s:show_diff(rootdir, q_args, winid, lnum, stay) abort
	let line = get(getbufline(winbufnr(a:winid), a:lnum), 0, '')
	if !empty(line)
		let path = a:rootdir .. '/' .. trim(split(line, "\t")[2])
		let cmd = 'git --no-pager diff -w ' .. a:q_args .. ' -- ' .. path
		call git#utils#open_diffwindow(a:rootdir, cmd, a:stay)
		call popup_setoptions(a:winid, git#utils#get_popupwin_options())
	endif
endfunction

function! git#diff#popup_callback(rootdir, q_args, winid, result) abort
	if -1 != a:result
		call s:show_diff(a:rootdir, a:q_args, a:winid, s:recently['lnum'], v:false)
	endif
endfunction

