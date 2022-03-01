
let g:loaded_gitroot = 1

command! -nargs=0 GitGotoRootDir :call s:gitgoto_rootdir()

function! s:gitgoto_rootdir() abort
	let cwd = getcwd()
	if filereadable(expand('%:p'))
		let cwd = fnamemodify(expand('%:p'), ':h')
	endif
	let path = s:get_gitrootdir(cwd)
	if !empty(path)
		execute 'lcd' path
		verbose pwd
	else
		call s:errormsg('Could not find any root directory under git control.')
	endif
endfunction

function! s:get_gitrootdir(path) abort
	let xs = split(fnamemodify(a:path, ':p'), '[\/]')
	let prefix = (has('mac') || has('linux')) ? '/' : ''
	while !empty(xs)
		let path = prefix .. join(xs + ['.git'], '/')
		if isdirectory(path) || filereadable(path)
			return prefix .. join(xs, '/')
		endif
		call remove(xs, -1)
	endwhile
	return ''
endfunction

function! s:errormsg(text) abort
	echohl ErrorMsg
	echo '[gitroot]' a:text
	echohl None
endfunction
