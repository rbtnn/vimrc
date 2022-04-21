
let g:loaded_popf = 1

if !has('nvim')
	command! -bang -nargs=0 Popf :call popf#exec(<q-bang>) 
endif

