
let g:loaded_git = 1

command! -nargs=? -bang  GitStat       :call git#cmd_stat(getcwd(), <q-bang>, <q-args>)
command! -nargs=? -bang  GitDiffThis   :call git#cmd_diffthis(getcwd(), <q-bang>, <q-args>)
command! -nargs=1        GitGrep       :call git#cmd_grep(getcwd(), <q-args>)

