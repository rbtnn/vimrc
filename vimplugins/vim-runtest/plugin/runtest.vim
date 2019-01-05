
let g:loaded_runtest = 1

command! -nargs=? -complete=customlist,runtest#comp RunTestStart :call runtest#start(<q-args>)
command! -nargs=0                                   RunTestStop  :call runtest#stop()

