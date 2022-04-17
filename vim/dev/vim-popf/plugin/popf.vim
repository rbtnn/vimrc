
let g:loaded_popf = 1

command! -bang -nargs=0 Popf :call popf#exec(<q-bang>) 

augroup popf
	autocmd!
	autocmd VimEnter * :call popf#pre_source()
augroup END

