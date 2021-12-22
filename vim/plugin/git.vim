
let g:loaded_git = 1

let s:TYPE_GITNUMSTAT = 'gitnumstat'
let s:TYPE_DIFF = 'diff'

command! -nargs=* GitDiff        :call s:gitdiffnumstat_open(<q-args>)
command! -nargs=0 GitGotoRootDir :call s:gitgoto_rootdir()

let s:this_script_id = expand('<SID>')

function! s:gitgoto_rootdir() abort
	let cwd = getcwd()
	if filereadable(expand('%:p'))
		let cwd = fnamemodify(expand('%:p'), ':h')
	endif
	let xs = split(cwd, '[\/]')
	let prefix = (has('mac') || has('linux')) ? '/' : ''
	while !empty(xs)
		let path = prefix .. join(xs + ['.git'], '/')
		if isdirectory(path) || filereadable(path)
			if !empty(path)
				execute 'lcd' (prefix .. join(xs, '/'))
				verbose pwd
			endif
			return 
		endif
		call remove(xs, -1)
	endwhile
	call s:errormsg('Could not find any root directory under git control.')
endfunction

function! s:gitdiffnumstat_open(q_args) abort
	let rootdir = s:get_gitrootdir(s:fixpath(fnamemodify('.', ':p')))
	if !executable('git')
		call s:errormsg('git is not executable.')
	elseif empty(rootdir)
		call s:errormsg('current directory is not a git repository.')
	else
		if !has('nvim')
			call s:gitdiffnumstat_popupwin(rootdir, split(a:q_args, '\s\+'))
		else
			call s:open_window(s:TYPE_GITNUMSTAT)
			call s:gitdiffnumstat_setlines(rootdir, split(a:q_args, '\s\+'))
		endif
	endif
endfunction

function! s:gitdiffnumstat_makelines(rootdir, args_list) abort
	let cmd = ['git', '--no-pager', 'diff', '--numstat'] + a:args_list
	let lines = []
	for line in s:system_for_gitoutput(cmd, a:rootdir)
		let m = matchlist(line, '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)$')
		if !empty(m)
			if ('0' != m[1]) || ('0' != m[2])
				let lines += [printf('%5s %5s %s', '+' .. m[1], '-' .. m[2], m[3])]
			endif
		else
			let lines += [line]
		endif
	endfor
	return lines
endfunction

function! s:gitdiffnumstat_popupwin(rootdir, args_list) abort
	let lines = s:gitdiffnumstat_makelines(a:rootdir, a:args_list)
	let winid = popup_menu(lines, {})
	call s:set_popupwinopts(winid, a:rootdir, a:args_list)
endfunction

function! s:set_popupwinopts(winid, rootdir, args_list) abort
	call popup_setoptions(a:winid, {
		\ 'title': printf(' [%s] args: %s ', s:TYPE_GITNUMSTAT, string(join(a:args_list))),
		\ 'cursorline': 1,
		\ 'padding': [1, 1, 1, 1],
		\ 'minheight': 3,
		\ 'filter': function('s:filter', [a:rootdir, a:args_list]),
		\ 'callback': function('s:callback', [a:rootdir, a:args_list]),
		\ })
	call win_execute(a:winid, 'setfiletype ' .. s:TYPE_GITNUMSTAT)
endfunction

function! s:filter(rootdir, args_list, winid, key) abort
	if a:key == 'W'
		let lines = s:gitdiffnumstat_makelines(a:rootdir, s:toggle_w(a:args_list))
		call popup_settext(a:winid, lines)
		call s:set_popupwinopts(a:winid, a:rootdir, s:toggle_w(a:args_list))
		return v:true
	else
		return popup_filter_menu(a:winid, a:key)
	endif
endfunction

function! s:callback(rootdir, args_list, winid, key) abort
	if 0 < a:key
		let lines = getbufline(winbufnr(a:winid), 1, '$')
		let line = lines[a:key - 1]
		if !empty(line)
			let m = matchlist(line, '^\s*+\d\+\s\+-\d\+\s\+\(.*\)$')
			if !empty(m)
				call s:open_window(s:TYPE_DIFF)
				call s:gitdiffshowdiff_setlines(a:rootdir, a:args_list, s:fixpath(a:rootdir .. '/' .. m[1]))
			endif
		endif
	endif
endfunction

function! s:gitdiffnumstat_setlines(rootdir, args_list) abort
	let view = winsaveview()
	let lines = s:gitdiffnumstat_makelines(a:rootdir, a:args_list)
	call s:setlines(a:rootdir, cmd, lines, s:TYPE_GITNUMSTAT)
	call s:buffer_nnoremap('<cr>', 'gitdiffshowdiff_open', [a:rootdir, a:args_list])
	call s:buffer_nnoremap('W', 'gitdiffnumstat_setlines', [a:rootdir, s:toggle_w(a:args_list)])
	call s:buffer_nnoremap('R', 'gitdiffnumstat_setlines', [a:rootdir, a:args_list])
	call winrestview(view)
endfunction

function! s:gitdiffshowdiff_open(rootdir, args_list) abort
	let line = getline('.')
	if !empty(line)
		let m = matchlist(line, '^\s*+\d\+\s\+-\d\+\s\+\(.*\)$')
		if !empty(m)
			call s:open_window(s:TYPE_DIFF)
			call s:gitdiffshowdiff_setlines(a:rootdir, a:args_list, s:fixpath(a:rootdir .. '/' .. m[1]))
		endif
	endif
endfunction

function! s:gitdiffshowdiff_setlines(rootdir, args_list, fullpath) abort
	let view = winsaveview()
	let cmd = ['git', '--no-pager', 'diff'] + a:args_list + ['--', a:fullpath]
	let lines = s:system_for_gitdiff(cmd, a:rootdir)
	call s:setlines(a:rootdir, cmd, lines, s:TYPE_DIFF)
	call s:buffer_nnoremap('<cr>', 'gitdiff_jumpdiffline', [a:fullpath])
	call s:buffer_nnoremap('W', 'gitdiffshowdiff_setlines', [a:rootdir, s:toggle_w(a:args_list), a:fullpath])
	call s:buffer_nnoremap('R', 'gitdiffshowdiff_setlines', [a:rootdir, a:args_list, a:fullpath])
	call winrestview(view)
endfunction

function! s:open_window(ft) abort
	let exists = v:false
	for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
		if getbufvar(w['bufnr'], '&filetype', '') == a:ft
			execute printf('%dwincmd w', w['winnr'])
			let exists = v:true
			break
		endif
	endfor
	if !exists
		new
		execute 'setfiletype' a:ft
	endif
endfunction

function! s:buffer_nnoremap(lhs, funcname, args) abort
	let format = 'nnoremap <silent><buffer>%s :<C-u>call %s%s(' .. join(repeat(['%s'], len(a:args)), ',') .. ')<cr>'
	let args = [format, a:lhs, s:this_script_id, a:funcname] + map(a:args, { i, x -> string(x) })
	execute call('printf', args)
endfunction

function! s:setlines(rootdir, cmd, lines, ft) abort
	if &filetype == a:ft
		setlocal modifiable noreadonly
		silent! call deletebufline(bufnr(), 1, '$')
		call setbufline(bufnr(), 1, [
			\ '# ' .. (strftime('%c')),
			\ '# [Git Directory]',
			\ '#   ' .. a:rootdir,
			\ '# [Command]',
			\ '#   ' .. join(a:cmd),
			\ '# [Keys]',
			\ '#   R: reload',
			\ '#   W: toggle -w option',
			\ ] + a:lines)
		setlocal buftype=nofile nomodifiable readonly
	endif
endfunction

function! s:toggle_w(args_list) abort
	let args_list = deepcopy(a:args_list)
	if -1 != index(args_list, '-w')
		call remove(args_list, '-w')
	else
		call insert(args_list, '-w')
	endif
	return args_list
endfunction

function! s:calc_lnum() abort
	let lines = getbufline(bufnr(), 1, '$')
	let curr_lnum = line('.')
	let lnum = -1

	for m in range(curr_lnum, 1, -1)
		if lines[m - 1] =~# '^@@'
			let lnum = m
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
					return { 'lnum': lnum, }
				endif
			endfor
		endif
	endif

	return {}
endfunction

function! s:gitdiff_jumpdiffline(fullpath) abort
	let x = s:calc_lnum()
	if !empty(x)
		if filereadable(a:fullpath)
			if s:find_window_by_path(a:fullpath)
				execute printf(':%d', x['lnum'])
			else
				new
				call s:open_file(a:fullpath, x['lnum'])
			endif
		endif
		normal! zz
	else
		call s:errormsg('can not jump this!')
	endif
endfunction

function! s:get_gitrootdir(path) abort
	let xs = split(a:path, '[\/]')
	let prefix = (has('mac') || has('linux')) ? '/' : ''
	while !empty(xs)
		let path = prefix .. join(xs + ['.git'], '/')
		if isdirectory(path) || filereadable(path)
			return s:fixpath(prefix .. join(xs, '/'))
		endif
		call remove(xs, -1)
	endwhile
	return ''
endfunction

function! s:fixpath(path) abort
	let xs = []
	for x in split(a:path, '[\/]\+')
		if (0 < len(xs)) && ('..' == x)
			let xs = xs[: -2]
		elseif '.' != x
			let xs += [x]
		endif
	endfor
	if (a:path =~# '^/') && !has('win32')
		return '/' .. join(xs, '/')
	elseif (join(xs, '/') =~# '^[A-Z]:$') && has('win32')
		return join(xs, '/') .. '/'
	else
		return empty(xs) ? '' : join(xs, '/')
	endif
endfunction

function! s:errormsg(text) abort
	echohl ErrorMsg
	echo '[git]' a:text
	echohl None
endfunction

function! s:system_for_gitdiff(cmd, cwd) abort
	let lines = s:system(a:cmd, a:cwd)
	let enc_from = ''
	for i in range(0, len(lines) - 1)
		" The encoding of top 4 lines('diff -...', 'index ...', '--- a/...', '+++ b/...') is always utf-8.
		if i < 4
			if 'utf-8' != &encoding
				let lines[i] = iconv(lines[i], 'utf-8', &encoding)
			endif
		else
			if empty(enc_from)
				if encoding#contains_multichar(lines[i])
					if encoding#is_utf8(lines[i])
						let enc_from = 'utf-8'
					else
						let enc_from = 'shift_jis'
					endif
				endif
			endif
			if !empty(enc_from) && (enc_from != &encoding)
				let lines[i] = iconv(lines[i], enc_from, &encoding)
			endif
		endif
	endfor
	return lines
endfunction

function! s:system_for_gitoutput(cmd, cwd) abort
	let lines = s:system(a:cmd, a:cwd)
	if 'utf-8' != &encoding
		for i in range(0, len(lines) - 1)
			let lines[i] = iconv(lines[i], 'utf-8', &encoding)
		endfor
	endif
	return lines
endfunction

function s:system_onevent(d, job, data, event) abort
	let a:d['lines'] += a:data
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
