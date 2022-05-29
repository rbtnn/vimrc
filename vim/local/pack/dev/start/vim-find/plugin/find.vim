
let g:loaded_find = 1

if !has('nvim')
	command! -bang -nargs=0 Find :call find#exec(<q-bang>) 
endif


