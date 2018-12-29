
let g:loaded_diffy = 1

command! -nargs=? -bang  Diffy       :call diffy#exec(getcwd(), <q-bang>, <q-args>)

