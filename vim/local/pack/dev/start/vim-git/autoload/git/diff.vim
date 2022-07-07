
function! git#diff#main(q_args) abort
	let cmd = 'git --no-pager diff --numstat -w ' .. a:q_args
	let rootdir = git#utils#get_rootdir('.', 'git')
	let winid = git#utils#create_popupwin(rootdir, [])
	if -1 != winid
		call popup_setoptions(winid, {
			\ 'filter': function('git#diff#popup_filter', [rootdir]),
			\ 'callback': function('git#diff#popup_callback', [rootdir, a:q_args]),
			\ })
		let lines = git#utils#system(cmd, rootdir)
		call popup_settext(winid, lines)
	endif
endfunction

function! git#diff#popup_filter(rootdir, winid, key) abort
	let lnum = line('.', a:winid)
	if (10 == char2nr(a:key)) || (14 == char2nr(a:key)) || (106 == char2nr(a:key))
		" Ctrl-n or Ctrl-j or j
		if lnum == line('$', a:winid)
			call git#utils#set_cursorline(a:winid, 1)
		else
			call git#utils#set_cursorline(a:winid, lnum + 1)
		endif
		return 1
	elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key)) || (107 == char2nr(a:key))
		" Ctrl-p or Ctrl-k or k
		if lnum == 1
			call git#utils#set_cursorline(a:winid, line('$', a:winid))
		else
			call git#utils#set_cursorline(a:winid, lnum - 1)
		endif
		return 1
	elseif 0x0d == char2nr(a:key)
		return popup_filter_menu(a:winid, "\<cr>")
	elseif char2nr(a:key) < 0x20
		return popup_filter_menu(a:winid, "\<esc>")
	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! git#diff#popup_callback(rootdir, q_args, winid, result) abort
	if -1 != a:result
		let line = get(getbufline(winbufnr(a:winid), a:result), 0, '')
		if !empty(line)
			let path = a:rootdir .. '/' .. trim(split(line, "\t")[2])
			let cmd = 'git --no-pager diff -w ' .. a:q_args .. ' -- ' .. path
			call git#utils#open_diffwindow()
			call git#diff#setlines(a:rootdir, cmd)
			execute printf('nnoremap <silent><buffer>R    :<C-u>call git#diff#setlines(%s, %s)<cr>', string(a:rootdir), string(cmd))
		endif
	endif
endfunction

function! git#diff#setlines(rootdir, cmd) abort
	let x = winsaveview()
	let lines = git#utils#system(a:cmd, a:rootdir)
	call git#utils#setlines(a:rootdir, a:cmd, lines)
	call winrestview(x)
endfunction

