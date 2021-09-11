
let g:loaded_gitdiff = 1

command! -nargs=0  FocusTerminal  :call s:focus_terminal()

function! s:focus_terminal() abort
	let xs = filter(getwininfo(), { i, x -> tabpagenr() == x['tabnr'] && x['terminal'] })
	if !empty(xs)
		execute printf('%dwincmd w', xs[0]['winnr'])
	else
	    terminal
	endif
endfunction

