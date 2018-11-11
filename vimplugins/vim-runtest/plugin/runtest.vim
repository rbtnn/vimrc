
let g:loaded_runtest = 1

command! -nargs=? -complete=customlist,runtest#comp RunTest :call runtest#exec(<q-args>)

