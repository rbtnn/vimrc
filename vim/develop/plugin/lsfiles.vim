
let g:loaded_develop_lsfiles = 1

command! -bang -nargs=*  LsFiles     :call lsfiles#exec(<q-bang>)

