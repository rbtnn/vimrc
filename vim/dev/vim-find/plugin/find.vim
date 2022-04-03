
let g:loaded_find = 1

command! -nargs=1 Find :call <SID>main(<q-args>) 

function! s:match(q_args, x) abort
	if a:x !~# ('\(' .. join([
		\ '\.\<\i\+\>', '\<AppData\>', '\<node_modules\>', '\<undofiles\>', '\<bin\>', '\<Library\>'
		\ ], '\|') .. '\)\/')
		if isdirectory(a:x)
			return v:true
		else
			if (a:x =~ a:q_args) && (-1 == index([
				\ 'png', 'exe', 'xpm', 'dll', 'gif', 'lib', 'zip',
				\ 'obj', 'o', 'dump', 'jpg'
				\ ], tolower(fnamemodify(a:x, ':e'))))
				return v:true
			endif
		endif
	endif
	return v:false
endfunction

function! s:readdir(q_args, path) abort
	if has('nvim')
		silent! return readdir(a:path, { x -> s:match(a:q_args, a:path .. '/' .. x) })
	else
		silent! return readdir(a:path, { x -> s:match(a:q_args, a:path .. '/' .. x) }, { 'sort': 'none', })
	endif
endfunction

function! s:setstatusline(text) abort
	let &l:statusline = printf('[Find] %s', a:text)
	redraw
endfunction

function! s:sub(q_args, path) abort
	try
		call s:setstatusline('Reading ' .. a:path)
		let dirs = []
		for x in s:readdir(a:q_args, a:path)
			let line = './' .. fnamemodify(a:path .. '/' .. x, ':.:gs?[\\/]\+?/?')
			if isdirectory(line)
				let dirs += [line]
			else
				call appendbufline(bufnr(), 0, line)
				call cursor(1, 1)
				call s:setstatusline('Matching ' .. line('$') .. ' files')
			endif
		endfor
		for x in dirs
			call s:sub(a:q_args, x)
		endfor
	catch /^Vim\%((\a\+)\)\=:E484:/
	endtry
endfunction

function! s:main(q_args) abort
	try
		silent! edit find://output
		setlocal buftype=nofile bufhidden=hide
		setfiletype find
		setlocal modifiable noreadonly
		call clearmatches(winnr())
		call matchadd('Search', a:q_args)
		silent! call deletebufline(bufnr(), 1, '$')
		let &l:statusline = printf('[Find] %d files', 0)
		call s:sub(a:q_args, '.')
		if empty(get(getbufline(bufnr(), '$'), 0, 'non-empty'))
			call deletebufline(bufnr(), '$')
			call s:setstatusline('Matching ' .. line('$') .. ' files')
		endif
	catch /^Vim:Interrupt$/
	finally
		setlocal nomodifiable readonly
	endtry
endfunction

