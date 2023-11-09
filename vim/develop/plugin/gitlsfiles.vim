
let g:loaded_develop_gitlsfiles = 1

command! -bang -nargs=*  GitLsFiles     :call gitlsfiles#exec(<q-bang>)

