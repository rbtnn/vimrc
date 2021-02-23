
let s:NUMSTAT_HEAD = 12

function! f#git#exec(currdir, q_args) abort
	try
		let args = split(a:q_args, '\s\+')
		let toplevel = s:get_toplevel_git(a:currdir)
		if isdirectory(toplevel)
			let dict = {}
			let cmd = ['git', '--no-pager', 'diff', '--numstat'] + args + ['.']
			for line in s:system(cmd, a:currdir, v:true)
				let m = matchlist(line, '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)$')
				if !empty(m)
					let key = m[3]
					if !has_key(dict, key)
						let dict[key] = { 'additions' : m[1], 'deletions' : m[2], 'path' : key, }
					endif
				endif
			endfor
			let lines = map(keys(dict), { i,key ->
				\ printf('%5s %5s %s', '+' .. dict[key]['additions'], '-' .. dict[key]['deletions'], key)
				\ })
			call sort(lines, { x,y ->
				\ x[(s:NUMSTAT_HEAD):] == y[(s:NUMSTAT_HEAD):]
				\ ? 0
				\ : x[(s:NUMSTAT_HEAD):] > y[(s:NUMSTAT_HEAD):]
				\   ? 1
				\   : -1
				\ })
			if !empty(lines)
				call s:new_window(lines, 'diffy', cmd)
				if hlexists('diffAdded')
					highlight default link diffyAdditions   diffAdded
				elseif hlexists('DiffAdd')
					highlight default link diffyAdditions   DiffAdd
				endif
				if hlexists('diffRemoved')
					highlight default link diffyDeletions   diffRemoved
				elseif hlexists('DiffDelete')
					highlight default link diffyDeletions   DiffDelete
				endif
				nnoremap <buffer><silent><nowait><space>    :<C-w>call <SID>show_diff()<cr>
				nnoremap <buffer><silent><nowait><cr>       :<C-w>call <SID>show_diff()<cr>
				let b:diffy = { 'toplevel' : toplevel, 'info' : [], 'args' : args, }
				let b:diffy['info'] = dict
			else
				call f#echo#error('No modified files')
			endif
		else
			call f#echo#error('Not a git repository')
		endif
	catch
		call f#echo#error(v:exception)
	endtry
endfunction

function! s:build_cmd(args, fullpath) abort
	return ['git', '--no-pager', 'diff'] + a:args + ['--', a:fullpath]
endfunction

function! s:show_diff() abort
	let info = b:diffy['info'][getline('.')[(s:NUMSTAT_HEAD):]]
	let toplevel = b:diffy['toplevel']
	let args = b:diffy['args']
	let cmd = s:build_cmd(args, info['path'])
	call s:new_window(s:system(cmd, toplevel, v:false), 'diff', cmd)
	let fullpath = s:expand2fullpath(toplevel .. '/' .. info['path'])
	execute printf('nnoremap <buffer><silent><nowait><space>    :<C-w>call <SID>jump_diff(%s)<cr>', string(fullpath))
	execute printf('nnoremap <buffer><silent><nowait><cr>       :<C-w>call <SID>jump_diff(%s)<cr>', string(fullpath))
	execute printf('nnoremap <buffer><silent><nowait>R          :<C-w>call <SID>rediff(%s, %s, %s)<cr>', string(toplevel), string(args), string(fullpath))
endfunction

function! s:rediff(toplevel, args, fullpath) abort
	let view = winsaveview()
	let cmd = s:build_cmd(a:args, a:fullpath)
	call s:new_window(s:system(cmd, a:toplevel, v:false), 'diff', cmd)
	call winrestview(view)
endfunction

function! s:jump_diff(fullpath) abort
	let ok = v:false
	let lnum = search('^@@', 'bnW')
	if 0 < lnum
		let n1 = 0
		let n2 = 0
		for n in range(lnum + 1, line('.'))
			let line = getline(n)
			if line =~# '^-'
				let n2 += 1
			elseif line =~# '^+'
				let n1 += 1
			endif
		endfor
		let n3 = line('.') - lnum - n1 - n2 - 1
		let m = []
		let m2 = matchlist(getline(lnum), '^@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\?\s*@@\(.*\)$')
		let m3 = matchlist(getline(lnum), '^@@@ \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\)\%(,\d\+\)\? \([+-]\)\(\d\+\),\d\+\s*@@@\(.*\)$')
		if !empty(m2)
			let m = m2
		elseif !empty(m3)
			let m = m3
		endif
		if !empty(m)
			for i in [1, 3, 5]
				if '+' == m[i]
					call s:open_file(a:fullpath, m[i + 1] + n1 + n3)
					let ok = v:true
					break
				endif
			endfor
		endif
	endif
	if !ok
		call f#echo#error('Can not jump this!')
	endif
endfunction

function! s:open_file(path, lnum) abort
	if filereadable(a:path)
		let fullpath = s:expand2fullpath(a:path)
		let b = 0
		for x in filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
			if s:expand2fullpath(bufname(x['bufnr'])) is fullpath
				execute x['winnr'] .. 'wincmd w'
				let b = 1
				break
			endif
		endfor
		if b
			execute printf('%d', a:lnum)
		else
			if 0 < a:lnum
				execute printf('new +%d %s', a:lnum, fnameescape(fullpath))
			else
				execute printf('new %s', fnameescape(fullpath))
			endif
		endif
		normal! zz
		return 1
	else
		return 0
	endif
endfunction

function! s:new_window(lines, filetype, cmd) abort
	let exists = v:false
	if get(g:, 'diffy_enable_singleton', v:true)
		for ft in ['diffy', 'diff']
			if ft == a:filetype
				for info in getwininfo()
					if (info['tabnr'] == tabpagenr()) && (getbufvar(info['bufnr'], '&filetype') == ft)
						execute printf('%dwincmd w', info['winnr'])
						setlocal noreadonly modifiable
						let exists = v:true
						break
					endif
				endfor
				break
			endif
		endfor
	endif
	if !exists
		new
	endif
	silent! call deletebufline('%', 1, '$')
	call setbufline('%', 1, a:lines)
	setlocal readonly nomodifiable buftype=nofile nocursorline
	let &l:filetype = a:filetype
	let &l:statusline = join(a:cmd)
endfunction

function! s:system(cmd, toplevel, is_git_output) abort
	let lines = []
	if exists('*job_start')
		let path = tempname()
		try
			let job = job_start(a:cmd, {
				\ 'cwd' : a:toplevel,
				\ 'out_io' : 'file',
				\ 'out_name' : path,
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
	else
		let saved = getcwd()
		try
			lcd `=a:toplevel`
			let lines = split(system(join(a:cmd)), "\n")
		finally
			lcd `=saved`
		endtry
	endif

	let enc_from = ''
	for i in range(0, len(lines) - 1)
		if a:is_git_output
			let lines[i] = s:iconv(lines[i], 'utf-8')
		else
			" The encoding of top 4 lines('diff -...', 'index ...', '--- a/...', '+++ b/...') is always utf-8.
			if i < 4
				let lines[i] = s:iconv(lines[i], 'utf-8')
			else
				" check if the line contains a multibyte-character.
				if 0 < len(filter(split(lines[i], '\zs'), {i,x -> 0x80 < char2nr(x) }))
					if empty(enc_from)
						if f#git#sillyiconv#utf_8(lines[i])
							let enc_from = 'utf-8'
						else
							let enc_from = 'shift_jis'
						endif
					endif
					let lines[i] = s:iconv(lines[i], enc_from)
				endif
			endif
		endif
	endfor

	return lines
endfunction

function! s:iconv(text, from) abort
	if a:from != &encoding
		return iconv(a:text, a:from, &encoding)
	else
		return a:text
	endif
endfunction

function! s:get_toplevel_git(currdir) abort
	let xs = split(a:currdir, '[\/]')
	let prefix = (has('mac') || has('linux')) ? '/' : ''
	while !empty(xs)
		if isdirectory(prefix .. join(xs + ['.git'], '/'))
			return s:expand2fullpath(prefix .. join(xs, '/'))
		endif
		call remove(xs, -1)
	endwhile
	return ''
endfunction

function! s:expand2fullpath(path) abort
	return substitute(resolve(fnamemodify(a:path, ':p')), '\', '/', 'g')
endfunction

