
let s:FILETYPE = 'F'

function! f#open(q_args) abort
	let rootdir = a:q_args
	if empty(rootdir)
	   	if filereadable(bufname())
			let rootdir = fnamemodify(bufname(), ':h')
		else
			let rootdir = getcwd()
		endif
	else
		if isdirectory(expand(rootdir))
			let rootdir = expand(rootdir)
		else
			let rootdir = getcwd()
		endif
	endif
	let rootdir = f#io#fix_path(rootdir)
	let lines = f#io#readdir(rootdir)
	call s:open(rootdir, lines, v:false, v:false)
endfunction

function! f#close() abort
	if s:is_near()
		" Does not close the Near window if here is CmdLineWindow.
		if ':' != getcmdtype()
			close
			if 0 < win_id2win(t:near['prev_winid'])
				execute printf('%dwincmd w', win_id2win(t:near['prev_winid']))
			endif
			call s:configure(v:true)
		endif
	endif
endfunction

function! f#search() abort
	if s:is_near()
		if t:near['is_driveletters']
			call f#echo#error('Can not search under the driveletters.')
		else
			let pattern = s:input_search_param('pattern', { v -> !empty(v) }, 'Please type a filename pattern!', '')
			if empty(pattern)
				return
			endif
			let maxdepth = s:input_search_param('max-depth', { v -> v =~# '^\d\+$' }, 'Please type a number as max-depth!', '3')
			if empty(maxdepth)
				return
			endif
			let rootdir = t:near['rootdir']
			setlocal noreadonly modified
			call clearmatches()
			call matchadd('Search', '\c' .. pattern[0])
			call s:set_statusline()
			silent! call deletebufline('%', 1, '$')
			redraw
			call f#io#search(rootdir, rootdir, pattern[0], str2nr(maxdepth[0]), 1, 1)
			setlocal buftype=nofile readonly nomodified nobuflisted
			let t:near['is_searchresult'] = v:true
			call s:set_statusline()
			call f#echo#info('Search has completed!')
		endif
	endif
endfunction

function! f#git_diff() abort
	if s:is_near()
		let rootdir = fnamemodify(t:near['rootdir'], ':p')
		call f#close()
		call f#git#exec(rootdir, '-w')
	endif
endfunction

function! f#select_file(line) abort
	if s:is_near()
		let path = f#io#fix_path((t:near['is_driveletters'] ? '' : (t:near['rootdir'] .. '/')) .. a:line)
		if filereadable(path)
			call f#close()
			if -1 == bufnr(path)
				execute printf('edit %s', escape(path, '#\ '))
			else
				execute printf('buffer %d', bufnr(path))
			endif
		elseif isdirectory(path)
			call f#open(path)
		endif
	endif
endfunction

function! f#updir() abort
	if s:is_near()
		if t:near['is_searchresult']
			if empty(t:near['rootdir'])
				call s:open(t:near['rootdir'], f#io#driveletters(), v:true, v:false)
			else
				let lines = f#io#readdir(t:near['rootdir'])
				call s:open(t:near['rootdir'], lines, v:false, v:false)
			endif
		elseif t:near['is_driveletters']
			" nop
		else
			let curdir = fnamemodify(t:near['rootdir'], ':p:h')
			if -1 != index(f#io#driveletters(), curdir)
				call s:open('', f#io#driveletters(), v:true, v:false)
				let pattern = curdir
			else
				let updir = fnamemodify(curdir, ':h')
				call f#open(updir)
				let pattern = fnamemodify(curdir, ':t') .. '/'
			endif
			call search('^' .. pattern .. '$')
			call feedkeys('zz', 'nx')
		endif
	endif
endfunction

function! f#change_dir() abort
	if s:is_near()
		let rootdir = t:near['rootdir']
		let view = winsaveview()
		call f#close()
		lcd `=rootdir`
		call f#open(rootdir)
		call winrestview(view)
	endif
endfunction

function! f#explorer() abort
	if s:is_near()
		if has('win32')
			let rootdir = fnamemodify(t:near['rootdir'], ':p')
			call f#close()
			execute '!start ' .. rootdir
		endif
	endif
endfunction

function! f#terminal() abort
	if s:is_near()
		let rootdir = t:near['rootdir']
		call f#close()
		if has('nvim')
			new
			call termopen(&shell, { 'cwd' : rootdir })
			startinsert
		else
			call term_start(&shell, { 'cwd' : rootdir, 'term_finish' : 'close' })
		endif
	endif
endfunction

function! f#help() abort
	if s:is_near()
		let xs = [
			\ ['Enter', 'Open a file or a directory under the cursor.'],
			\ ['Space', 'Open a file or a directory under the cursor.'],
			\ ['Esc', 'Close the Near window.'],
			\ ['T', 'Open a terminal window.'],
			\ ['S', 'Search a file by filename pattern matching.'],
			\ ['E', 'Open a explorer.exe. (Windows OS only)'],
			\ ['L', 'Open a file or a directory under the cursor.'],
			\ ['H', 'Go up to parent directory.'],
			\ ['C', 'Change the current directory to the Near''s directory.'],
			\ ['~', 'Change the current directory to Home directory.'],
			\ ['?', 'Print this help.'],
			\ ]
		for x in xs
			call f#echo#info(' ' .. x[0] .. ' key : ')
			echon x[1]
		endfor
	endif
endfunction



function! s:open(rootdir, lines, is_driveletters, is_searchresult) abort
	if !empty(a:lines)
		if &filetype == s:FILETYPE
			call f#close()
		endif
		let t:near = {
			\ 'prev_winid' : win_getid(),
			\ 'rootdir' : a:rootdir,
			\ 'is_driveletters' : a:is_driveletters,
			\ 'is_searchresult' : a:is_searchresult,
			\ }
		vnew
		let t:near['near_winid'] = win_getid()
		setlocal noreadonly modified
		silent! call deletebufline('%', 1, '$')
		call setbufline('%', 1, a:lines)
		let width = max(map(copy(a:lines), { _,x -> strdisplaywidth(x) })) + 1
		execute printf('vertical resize %d', width)
		setlocal buftype=nofile readonly nomodified nobuflisted
		let &l:filetype = s:FILETYPE
		call s:set_statusline()
	else
		call f#echo#error(printf('There are no files or directories in "%s".', a:rootdir))
	endif
endfunction

function! s:set_statusline() abort
	let &l:statusline = printf('[%s] %%l/%%L ', s:FILETYPE)
endfunction

function! s:is_near() abort
	call s:configure(v:false)
	return (t:near['near_winid'] == win_getid()) && (&filetype == s:FILETYPE)
endfunction

function! s:configure(force_init) abort
	if a:force_init
		let t:near = {}
	else
		let t:near = get(t:, 'near', {})
	endif
	let t:near['near_winid'] = get(t:near, 'near_winid', -1)
	let t:near['prev_winid'] = get(t:near, 'prev_winid', -1)
	let t:near['rootdir'] = get(t:near, 'rootdir', '.')
	let t:near['is_driveletters'] = get(t:near, 'is_driveletters', v:false)
	let t:near['is_searchresult'] = get(t:near, 'is_searchresult', v:false)
endfunction

function! s:input_search_param(name, chk_cb, errmsg, default) abort
	echohl Title
	let v = input(a:name .. '>', a:default)
	echohl None
	if a:chk_cb(v)
		return [v]
	else
		echo ' '
		call f#echo#error(a:errmsg)
		return []
	endif
endfunction

