
let g:loaded_develop_ripgrep = 1

if executable('rg')
    command! -nargs=* RipGrepSearch  :call ripgrep#search(<q-args>)
    command! -nargs=* RipGrepFiles   :call ripgrep#files(<q-args>)
endif

