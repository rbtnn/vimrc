
let g:loaded_develop_mrd = 1

command! -nargs=0 MRD :call mrd#exec()

augroup MRD
    autocmd!
    autocmd DirChanged * :call mrd#update_dir()
augroup END
