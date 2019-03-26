
let g:loaded_rbtnn = 1

command! -nargs=0        ReadingVimrc  :call readingvimrc#open_list()
command! -nargs=?        MSBuild       :call msbuild#exec(<q-args>)

