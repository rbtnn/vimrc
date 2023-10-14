
let g:loaded_develop_gitblame = 1

if executable('git')
    command! -nargs=0 GitBlameCurrentLine   :echo trim(system(printf('git blame -L %d,%d -- %s', line('.'), line('.'), expand('%'))))
endif
