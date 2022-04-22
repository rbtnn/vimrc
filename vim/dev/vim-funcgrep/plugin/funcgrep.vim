
let g:loaded_funcgrep = 1

augroup funcgrep
	autocmd!
	autocmd FileType     cs :command! -buffer -nargs=0 FuncGrep  :execute 'vimgrep /^\s*\(public\s\+\|private\s\+\)\?\(static\s\+\)\?[a-zA-Z0-9_<>]\+\s\+\zs\i\+\ze(/j %'
	autocmd FileType  c,cpp :command! -buffer -nargs=0 FuncGrep  :execute 'vimgrep /^\%(.*\<if\>\|.*\<return\>\)\@!\s*\(static\s\+\)\?\i\+\**\_s\+\zs\i\+\ze(\_[^=)]\{-})/j %'
	autocmd FileType    vim :command! -buffer -nargs=0 FuncGrep  :execute 'vimgrep /^\s*fu\%[nction]!\?\s\+\zs[a-zA-Z0-9_#:]\+\ze\s*(/j %'
	autocmd FileType     vb :command! -buffer -nargs=0 FuncGrep  :execute 'vimgrep /^\s*\(Public\s\+\|Private\s\+\)\?\(Function\|Sub\|Property\)\s\+\zs\i\+\ze\s*(/j %'
augroup END
