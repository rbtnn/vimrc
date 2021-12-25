
let g:loaded_gitroot = 1

command! -nargs=0 GitGotoRootDir :call s:gitgoto_rootdir()

function! s:gitgoto_rootdir() abort
	let cwd = getcwd()
	if filereadable(expand('%:p'))
		let cwd = fnamemodify(expand('%:p'), ':h')
	endif
	let path = vimrc#git#get_rootdir(cwd)
	if !empty(path)
		execute 'lcd' path
		verbose pwd
	else
		call s:errormsg('Could not find any root directory under git control.')
	endif
endfunction

function! s:errormsg(text) abort
	echohl ErrorMsg
	echo '[gitroot]' a:text
	echohl None
endfunction
