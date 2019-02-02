
let g:loaded_diffy = 1

command! -nargs=? -bang  Diffy       :call diffy#exec(fnamemodify(expand('%'), ':h'), <q-bang>, <q-args>)

