
let g:loaded_rbtnn = 1

call tabenhancer#init()

command! -nargs=0        ReadingVimrc  :call readingvimrc#open_list()
command! -nargs=0        JobKill       :call jobrunner#killall()
command! -nargs=?        MSBuild       :call msbuild#exec(<q-args>)

augroup repositories
    autocmd!
    autocmd WinEnter *  :call repositories#winenter()
    autocmd BufEnter *  :call repositories#bufenter()
augroup END

command! -nargs=0 -bar Repositories :call repositories#exec()
