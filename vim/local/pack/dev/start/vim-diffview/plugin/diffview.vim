
let g:loaded_diffview = 1

command! -nargs=* DiffViewGit   :call s:main('git --no-pager diff -w ', <q-args>)
command! -nargs=* DiffViewSvn   :call s:main('svn diff -x -w ', <q-args>)
command! -nargs=1 DiffViewOneCommitGit   :call s:main_one_commit('git --no-pager diff -w ', <q-args>)

function! s:main(cmd, q_args) abort
	let cmd = ''
	if (a:cmd =~# 'git') && !empty(s:get_rootdir('.', 'git'))
		let cmd = a:cmd .. a:q_args
	elseif (a:cmd =~# 'svn') && !empty(s:get_rootdir('.', 'svn'))
		let cmd = a:cmd .. a:q_args
	endif
	let rootdir = s:get_rootdir('.', get(split(cmd), 0, ''))
	if !empty(cmd) && !empty(rootdir)
		let lines = s:system(cmd, rootdir)
		if !empty(lines)
			call s:open_window()
			call s:setlines(rootdir, cmd, lines)
		else
			echohl Error
			echo '[diffview] The modified file was not found!'
			echohl None
		endif
	endif
endfunction

function! s:main_one_commit(cmd, hash) abort
	call s:main(a:cmd, printf('%s~1..%s', a:hash, a:hash))
endfunction

function! s:get_rootdir(path, cmdname) abort
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

function! s:open_window() abort
	let exists = v:false
	for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
		if getbufvar(w['bufnr'], '&filetype', '') == 'diff'
			execute printf('%dwincmd w', w['winnr'])
			let exists = v:true
			break
		endif
	endfor
	if !exists
		rightbelow vnew
		setfiletype diff
	endif
endfunction

function! s:setbuflines(lines) abort
	setlocal modifiable noreadonly
	silent! call deletebufline(bufnr(), 1, '$')
	call setbufline(bufnr(), 1, a:lines)
	setlocal buftype=nofile nomodifiable readonly
endfunction

function! s:setlines(rootdir, cmd, lines) abort
	let view = winsaveview()
	let &l:statusline = a:cmd
	call s:setbuflines(a:lines)
	let b:diffview = {
		\ 'cmd': a:cmd,
		\ 'rootdir': a:rootdir,
		\ }
	nnoremap  <buffer><cr>  <Cmd>:call <SID>jumpdiffline(b:diffview['rootdir'])<cr>
	call winrestview(view)

	" Redraw windows because the encoding process is very slowly.
	redraw

	" The lines encodes after redrawing.
	for i in range(0, len(a:lines) - 1)
		let enc_from = ''
		if diffview#encoding#contains_multichar(a:lines[i])
			if diffview#encoding#is_utf8(a:lines[i])
				let enc_from = 'utf-8'
			else
				let enc_from = 'shift_jis'
			endif
		endif
		if !empty(enc_from) && (enc_from != &encoding)
			let a:lines[i] = iconv(a:lines[i], enc_from, &encoding)
		endif
	endfor
	call s:setbuflines(a:lines)
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

function! s:open_file(path, lnum) abort
	let bnr = s:strict_bufnr(a:path)
	if -1 == bnr
		execute printf('edit %s', fnameescape(a:path))
	else
		silent! execute printf('buffer %d', bnr)
	endif
	if 0 < a:lnum
		call cursor([a:lnum, 1])
	endif
endfunction

function! s:jumpdiffline(rootdir) abort
	let x = s:calc_lnum(a:rootdir)
	if !empty(x)
		if filereadable(x['path'])
			if s:find_window_by_path(x['path'])
				execute printf(':%d', x['lnum'])
			else
				new
				call s:open_file(x['path'], x['lnum'])
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

function s:system(cmd, cwd) abort
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
			if filereadable(path)
				let lines = readfile(path)
			endif
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

function s:system_onevent(d, job, data, event) abort
	let a:d['lines'] += a:data
	sleep 10m
endfunction

