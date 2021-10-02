
let g:loaded_find = 1

let s:DEF_DIRS = map(['node_modules', 'AppData', 'undofiles', '\..\+'], '"^" .. v:val .. "$"')
let s:DEF_EXTS = map(['exe', 'dll', 'obj', 'png', 'lnk', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'lib', 'log'], '"^" .. v:val .. "$"')
let s:DEF_DPH = 10
let s:DEF_CNT = 10000

command! -nargs=* Find :call s:main(<q-args>)

augroup find
	autocmd!
	autocmd FileType   find :nnoremap <buffer><cr>    gf
	autocmd FileType   find :nnoremap <buffer><space> gf
augroup END

function! s:match_excludes(patterns, name) abort
	for pattern in a:patterns
		if a:name =~ pattern
			return v:true
		endif
	endfor
	return v:false
endfunction

function! s:tree(depth, dir, _) abort
	if a:depth <= a:_['find_maximum_depth']
		for name in s:readdir(a:dir)
			if a:_['find_maximum_count'] < line('$')
				break
			endif
			let path = a:dir .. '/' .. name
			let ext = fnamemodify(name, ':e')
			if isdirectory(path)
				if !s:match_excludes(a:_['find_exclude_dirs'], name)
					call s:tree(a:depth + 1, path, a:_)
				endif
			elseif (path =~ a:_['pattern']) && !s:match_excludes(a:_['find_exclude_exts'], ext)
				silent! call appendbufline(bufnr(), '$', [path])
			endif
		endfor
	endif
endfunction

function! s:readdir(dir) abort
	let xs = []
	try
		if has('nvim')
			silent! let xs = readdir(a:dir, '1')
		else
			silent! let xs = readdir(a:dir, '1', { 'sort': 'none', })
		endif
	catch /^Vim\%((\a\+)\)\=:E484:/
		" skip the directory.
		" E484: Can't open file ...
	endtry
	return xs
endfunction

function! s:main(q_args) abort
	try
		" use the old find buffer if exists
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
			setlocal buftype=nofile bufhidden=hide cursorline
		endif
		setlocal modifiable noreadonly
		silent! call deletebufline(bufnr(), 1, '$')
		call s:tree(0, '.', {
			\ 'pattern': a:q_args,
			\ 'find_maximum_depth': get(g:, 'find_maximum_depth', s:DEF_DPH),
			\ 'find_maximum_count': get(g:, 'find_maximum_count', s:DEF_CNT),
			\ 'find_exclude_dirs': get(g:, 'find_exclude_dirs', s:DEF_DIRS),
			\ 'find_exclude_exts': get(g:, 'find_exclude_exts', s:DEF_EXTS),
			\ })
		silent! call deletebufline(bufnr(), 1, 1)
		setlocal nomodifiable readonly
		call cursor(1, 1)
		" open the file if the number of result is 1.
		if (1 == line('$')) && filereadable(getline(1))
			normal! gf
		else
			let @/ = a:q_args
		endif
	catch
		echohl Error
		echo '[find]' v:exception
		echohl None
	endtry
endfunction

