
let g:loaded_gitdiff = 1

let s:TYPE_NUMSTAT = 'TYPE_NUMSTAT'
let s:TYPE_SHOWDIFF = 'TYPE_SHOWDIFF'

command! -nargs=* GitDiff  :call s:gitdiffnumstat_open(<q-args>)

let s:this_script_id = expand('<SID>')

function! s:gitdiffnumstat_open(q_args) abort
	let rootdir = s:get_gitrootdir(s:fixpath(fnamemodify('.', ':p')))
	if !executable('git')
		call s:errormsg('git is not executable.')
	elseif empty(rootdir)
		call s:errormsg('current directory is not a git repository.')
	else
		call s:open_window(s:TYPE_NUMSTAT)
		call s:gitdiffnumstat_setlines(rootdir, split(a:q_args, '\s\+'))
	endif
endfunction

function! s:gitdiffnumstat_setlines(rootdir, args_list) abort
	let view = winsaveview()
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
	call s:setlines(a:rootdir, cmd, lines, 'gitdiff')
	call s:buffer_nnoremap('<cr>', 'gitdiffshowdiff_open', [a:rootdir, a:args_list])
	call s:buffer_nnoremap('<space>', 'gitdiffshowdiff_open', [a:rootdir, a:args_list])
	call s:buffer_nnoremap('w', 'gitdiffnumstat_setlines', [a:rootdir, s:toggle_w(a:args_list)])
	call s:buffer_nnoremap('r', 'gitdiffnumstat_setlines', [a:rootdir, a:args_list])
	call winrestview(view)
endfunction

function! s:gitdiffshowdiff_open(rootdir, args_list) abort
	let line = getline('.')
	if !empty(line)
		let m = matchlist(line, '^\s*+\d\+\s\+-\d\+\s\+\(.*\)$')
		if !empty(m)
			call s:open_window(s:TYPE_SHOWDIFF)
			call s:gitdiffshowdiff_setlines(a:rootdir, a:args_list, s:fixpath(a:rootdir .. '/' .. m[1]))
		endif
	endif
endfunction

function! s:gitdiffshowdiff_setlines(rootdir, args_list, fullpath) abort
	let view = winsaveview()
	let cmd = ['git', '--no-pager', 'diff'] + a:args_list + ['--', a:fullpath]
	let lines = s:system_for_gitdiff(cmd, a:rootdir)
	call s:setlines(a:rootdir, cmd, lines, 'diff')
	call s:buffer_nnoremap('<cr>', 'gitdiff_jumpdiffline', [a:fullpath])
	call s:buffer_nnoremap('<space>', 'gitdiff_jumpdiffline', [a:fullpath])
	call s:buffer_nnoremap('w', 'gitdiffshowdiff_setlines', [a:rootdir, s:toggle_w(a:args_list), a:fullpath])
	call s:buffer_nnoremap('r', 'gitdiffshowdiff_setlines', [a:rootdir, a:args_list, a:fullpath])
	call winrestview(view)
endfunction

function! s:open_window(t) abort
	let exists = v:false
	for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
		let x = getbufvar(w['bufnr'], 'gitdiff', {})
		if get(x, 'type', '') == a:t
			execute printf('%dwincmd w', w['winnr'])
			let exists = v:true
			break
		endif
	endfor
	if !exists
		new
		let b:gitdiff = { 'type': a:t, }
	endif
endfunction

function! s:buffer_nnoremap(lhs, funcname, args) abort
	let format = 'nnoremap <silent><buffer>%s :<C-u>call %s%s(' .. join(repeat(['%s'], len(a:args)), ',') .. ')<cr>'
	let args = [format, a:lhs, s:this_script_id, a:funcname] + map(a:args, { i, x -> string(x) })
	execute call('printf', args)
endfunction

function! s:setlines(rootdir, cmd, lines, ft) abort
	setlocal modifiable noreadonly
	silent! call deletebufline(bufnr(), 1, '$')
	call setbufline(bufnr(), 1, [
		\ '# ' .. (strftime('%c')),
		\ '# ' .. a:rootdir,
		\ '# ' .. join(a:cmd)
		\ ] + a:lines)
	setlocal buftype=nofile nomodifiable readonly
	execute 'setfiletype' a:ft
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

function! s:gitdiff_jumpdiffline(fullpath) abort
	let lines = getbufline(bufnr(), 1, '$')
	let curr_lnum = line('.')
	let ok = v:false
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
					if filereadable(a:fullpath)
						let lnum = str2nr(m[i + 1]) + n1 + n3
						if s:find_window_by_path(a:fullpath)
							execute printf(':%d', lnum)
						else
							new
							call s:open_file(a:fullpath, lnum)
						endif
					endif
					let ok = v:true
					break
				endif
			endfor
		endif
	endif

	if !ok
		call s:errormsg('can not jump this!')
	endif
endfunction

function! s:get_gitrootdir(path) abort
	let xs = split(a:path, '[\/]')
	let prefix = (has('mac') || has('linux')) ? '/' : ''
	while !empty(xs)
		if isdirectory(prefix .. join(xs + ['.git'], '/'))
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
	echohl Error
	echo '[gitdiff]' a:text
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

function s:system_onevnet(d, job, data, event) abort
	let a:d['lines'] += a:data
endfunction

function s:system(cmd, cwd) abort
	let lines = []
	if has('nvim')
		let job = jobstart(a:cmd, {
			\ 'cwd': a:cwd,
			\ 'on_stdout': function('s:system_onevnet', [{ 'lines': lines, }]),
			\ 'on_stderr': function('s:system_onevnet', [{ 'lines': lines, }]),
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
