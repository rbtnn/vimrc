
let g:loaded_rbtnn = 1

call tabenhancer#init()

command! -nargs=0        ReadingVimrc  :call readingvimrc#open_list()
command! -nargs=0        JobKill       :call jobrunner#killall()
command! -nargs=?        MSBuild       :call msbuild#exec(<q-args>)

