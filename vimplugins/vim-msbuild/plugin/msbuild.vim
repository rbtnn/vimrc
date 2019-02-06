
let g:loaded_msbuild = 1

command! -nargs=? MSBuild :call msbuild#exec(<q-bang>)

