
let g:loaded_develop_ripgrep = 1

command! -nargs=0 RipGrepLive    :call ripgrep#livegrep()
command! -nargs=0 RipGrepFiles   :call ripgrep#files()
