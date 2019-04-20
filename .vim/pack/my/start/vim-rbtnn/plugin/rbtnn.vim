
scriptversion 3

let g:loaded_rbtnn = 1

command! -nargs=0        ReadingVimrc  :call readingvimrc#open_list()

command! -nargs=1        MSBuildNew       :call msbuild#new(<q-args>)
command! -nargs=?        MSBuildBuild     :call msbuild#build(<q-args>)
command! -nargs=?        MSBuildRun       :call msbuild#run(<q-args>)

