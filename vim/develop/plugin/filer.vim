
let g:loaded_develop_filer = 1

command!       -nargs=0  Filer    :call filer#exec(filereadable(expand('%')) ? expand('%:h') : '.')
