
let g:loaded_job = 1

command! -nargs=0 -bang  JobKill   :call job#kill()
command! -nargs=0 -bang  JobList   :call job#list()
"
