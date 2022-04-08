
let g:loaded_find = 1

command! -nargs=? Find :call <SID>main() 

function! s:match(q_args, x) abort
	if a:x !~# ('\(' .. join([
		\ '\.\<\i\+\>', '\<AppData\>', '\<node_modules\>', '\<undofiles\>', '\<bin\>', '\<Library\>', '\<obj\>',
		\ ], '\|') .. '\)\/')
		if isdirectory(a:x)
			return v:true
		else
			if (a:x =~ a:q_args) && (-1 == index([
				\ 'png', 'exe', 'xpm', 'dll', 'gif', 'lib', 'zip',
				\ 'obj', 'o', 'dump', 'jpg', 'ico',
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

function! s:setstatusline() abort
	let n = line('$')
	if empty(get(getbufline(bufnr(), '$'), 0, ''))
		let n = 0
	endif
	let &l:statusline = printf('[Find] %d files', n)
	redraw
endfunction

function! s:sub(q_args, path) abort
	try
		let dirs = []
		let file_exists = v:false
		for x in s:readdir(a:q_args, a:path)
			let line = './' .. fnamemodify(a:path .. '/' .. x, ':.:gs?[\\/]\+?/?')
			if isdirectory(line)
				let dirs += [line]
			else
				call appendbufline(bufnr(), 0, line)
				let file_exists = v:true
			endif
		endfor
		if file_exists
			call s:setstatusline()
		endif
		for x in dirs
			call s:sub(a:q_args, x)
		endfor
	catch /^Vim\%((\a\+)\)\=:E484:/
	endtry
endfunction

function! s:open_file() abort
	let line = get(getbufline(bufnr(), line('.')), 0, '')
	if filereadable(line)
		execute printf('edit %s', fnameescape(line))
	endif
endfunction

function! s:main() abort
	try
		let exists = v:false
		for x in getbufinfo()
			if 'find' == getbufvar(x['bufnr'], '&filetype', '')
				let exists = v:true
				execute printf('%dbuffer', x['bufnr'])
				break
			endif
		endfor
		if !exists
			silent! edit find://output
			setfiletype find
			setlocal buftype=nofile bufhidden=hide
		endif
		nnoremap <buffer><cr>  <Cmd>call <SID>open_file()<cr>
		call s:setstatusline()
		redraw
		let text = input(getcwd() .. '>')
		if !empty(text)
			setlocal modifiable noreadonly
			silent! call deletebufline(bufnr(), 1, '$')
			call s:sub(text, '.')
			if empty(get(getbufline(bufnr(), '$'), 0, 'non-empty'))
				call deletebufline(bufnr(), '$')
			endif
		endif
	catch /^Vim:Interrupt$/
	finally
		setlocal nomodifiable readonly
		call cursor(1, 1)
		call s:setstatusline()
	endtry
endfunction

