
let g:loaded_gitroot = 1

command! -nargs=0 GitGotoRootDir :call s:gitgoto_rootdir()

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

function! s:errormsg(text) abort
	echohl ErrorMsg
	echo '[gitroot]' a:text
	echohl None
endfunction
