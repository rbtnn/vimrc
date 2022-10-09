
scriptencoding utf-8

function! git#utils#can_open_in_current() abort
	let tstatus = term_getstatus(bufnr())
	if (tstatus != 'finished') && !empty(tstatus)
		return v:false
	elseif !empty(getcmdwintype())
		return v:false
	elseif &modified
		return v:false
	else
		return v:true
	endif
endfunction

function! git#utils#get_popupwin_options() abort
	const hiname = 'Normal'
	let w = getwininfo(win_getid())[0]
	let winrow = w['winrow']
	let wincol = w['wincol']
	let width = w['width']
	let height = w['height']
	let opts = {
		\ 'wrap': 1,
		\ 'scrollbar': 0,
		\ 'minwidth': width, 'maxwidth': width,
		\ 'minheight': height, 'maxheight': height,
		\ 'pos': 'topleft',
		\ 'line': winrow,
		\ 'col': wincol,
		\ 'border': [0, 0, 0, 0],
		\ 'padding': [0, 0, 0, 0],
		\ 'highlight': hiname,
		\ }
	if 0 && (has('gui_running') || (!has('win32') && !has('gui_running')))
		" ┌──┐
		" │  │
		" └──┘
		const borderchars_typeA = [
			\ nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
			\ nr2char(0x250c), nr2char(0x2510), nr2char(0x2518), nr2char(0x2514)]
		" ╭──╮
		" │  │
		" ╰──╯
		const borderchars_typeB = [
			\ nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
			\ nr2char(0x256d), nr2char(0x256e), nr2char(0x256f), nr2char(0x2570)]
		call extend(opts, {
			\ 'border': [],
			\ 'borderhighlight': repeat([hiname], 4),
			\ 'borderchars': borderchars_typeA,
			\ }, 'force')
	endif
	return opts
endfunction

function! git#utils#get_rootdir(path, cmdname) abort
	let xs = split(fnamemodify(a:path, ':p'), '[\/]')
	let prefix = (has('mac') || has('linux')) ? '/' : ''
	while !empty(xs)
		let path = prefix .. join(xs + ['.' .. a:cmdname], '/')
		if isdirectory(path) || filereadable(path)
			return prefix .. join(xs, '/')
		endif
		call remove(xs, -1)
	endwhile
	return ''
endfunction

function! git#utils#goto_rootdir() abort
	let path = expand('%:p')
	if filereadable(path)
		let path = fnamemodify(path, ':h')
	else
		let path = getcwd()
	endif
	let path = git#utils#get_rootdir(path, 'git')
	if !empty(path)
		call chdir(path)
	endif
	verbose pwd
endfunction

function! git#utils#open_diffwindow(rootdir, cmd, stay) abort
	let wnr = winnr()
	let lnum = line('.')

	let exists = v:false
	for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
		if getbufvar(w['bufnr'], '&filetype', '') == 'diff'
			execute printf('%dwincmd w', w['winnr'])
			let exists = v:true
			break
		endif
	endfor
	if !exists
		botright vnew
		setfiletype diff
		setlocal nolist
	endif

	let lines = git#utils#system(a:cmd, a:rootdir)

	let &l:statusline = a:cmd
	call s:setbuflines(lines)
	let b:diffview = {
		\ 'cmd': a:cmd,
		\ 'rootdir': a:rootdir,
		\ }

	nnoremap         <buffer><cr>  <Cmd>call <SID>jumpdiffline(b:diffview['rootdir'])<cr>
	nnoremap         <buffer>R     <Cmd>call git#utils#open_diffwindow(b:diffview['rootdir'], b:diffview['cmd'], v:true)<cr>

	" Redraw windows because the encoding process is very slowly.
	redraw

	" The lines encodes after redrawing.
	for i in range(0, len(lines) - 1)
		let lines[i] = qficonv#encoding#iconv_utf8(lines[i], 'shift_jis')
	endfor
	call s:setbuflines(lines)

	if a:stay
		execute printf(':%dwincmd w', wnr)
		call cursor(lnum, 0)
	endif
endfunction

function! git#utils#open_file(path, lnum) abort
	const ok = git#utils#can_open_in_current()
	let bnr = s:strict_bufnr(a:path)
	if bufnr() == bnr
		" nop if current buffer is the same
	elseif ok
		if -1 == bnr
			execute printf('edit %s', fnameescape(a:path))
		else
			silent! execute printf('buffer %d', bnr)
		endif
	else
		execute printf('new %s', fnameescape(a:path))
	endif
	if 0 < a:lnum
		call cursor([a:lnum, 1])
	endif
endfunction

function git#utils#system(cmd, cwd) abort
	let lines = []
	if has('nvim')
		let job = jobstart(a:cmd, {
			\ 'cwd': a:cwd,
			\ 'on_stdout': function('s:system_onevent', [{ 'lines': lines, }]),
			\ 'on_stderr': function('s:system_onevent', [{ 'lines': lines, }]),
			\ })
		call jobwait([job])
	else
		let path = tempname()
		try
			let job = job_start(a:cmd, {
				\ 'cwd': a:cwd,
				\ 'out_io': 'file',
				\ 'out_name': path,
				\ 'err_io': 'out',
				\ })
			while 'run' == job_status(job)
			endwhile
			if filereadable(path)
				let lines = readfile(path)
			endif
		finally
			if filereadable(path)
				call delete(path)
			endif
		endtry
	endif
	return lines
endfunction

function! git#utils#set_cursorline(winid, lnum) abort
	call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
	call win_execute(a:winid, 'redraw')
endfunction



function s:system_onevent(d, job, data, event) abort
	let a:d['lines'] += a:data
	sleep 10m
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

function! s:setbuflines(lines) abort
	setlocal modifiable noreadonly
	silent! call deletebufline(bufnr(), 1, '$')
	call setbufline(bufnr(), 1, a:lines)
	setlocal buftype=nofile nomodifiable readonly
endfunction

function! s:jumpdiffline(rootdir) abort
	let x = s:calc_lnum(a:rootdir)
	if !empty(x)
		if filereadable(x['path'])
			if s:find_window_by_path(x['path'])
				execute printf(':%d', x['lnum'])
			else
				new
				call git#utils#open_file(x['path'], x['lnum'])
			endif
		endif
		normal! zz
	endif
endfunction

function! s:calc_lnum(rootdir) abort
	let lines = getbufline(bufnr(), 1, '$')
	let curr_lnum = line('.')
	let lnum = -1
	let relpath = ''

	for m in range(curr_lnum, 1, -1)
		if lines[m - 1] =~# '^@@'
			let lnum = m
			break
		endif
	endfor
	for m in range(curr_lnum, 1, -1)
		if lines[m - 1] =~# '^+++ '
			let relpath = matchstr(lines[m - 1], '^+++ \zs.\+$')
			let relpath = substitute(relpath, '^b/', '', '')
			let relpath = substitute(relpath, '\s\+(working copy)$', '', '')
			let relpath = substitute(relpath, '\s\+(revision \d\+)$', '', '')
			break
		endif
	endfor

	if (lnum < curr_lnum) && (0 < lnum)
		let n1 = 0
		let n2 = 0
		for n in range(lnum + 1, curr_lnum)
			let line = lines[n - 1]
			if line =~# '^-'
				let n2 += 1
			elseif line =~# '^+'
				let n1 += 1
			endif
		endfor
		let n3 = curr_lnum - lnum - n1 - n2 - 1
		let m = []
		let m2 = matchlist(lines[lnum - 1], '^@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\?\s*@@\(.*\)$')
		let m3 = matchlist(lines[lnum - 1], '^@@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@@\(.*\)$')
		if !empty(m2)
			let m = m2
		elseif !empty(m3)
			let m = m3
		endif
		if !empty(m)
			for i in [1, 3, 5]
				if '+' == m[i]
					let lnum = str2nr(m[i + 1]) + n1 + n3
					return { 'lnum': lnum, 'path': expand(a:rootdir .. '/' .. relpath) }
				endif
			endfor
		endif
	endif

	return {}
endfunction

function! s:find_window_by_path(path) abort
	for x in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
		if x['bufnr'] == s:strict_bufnr(a:path)
			execute printf(':%dwincmd w', x['winnr'])
			return v:true
		endif
	endfor
	return v:false
endfunction

