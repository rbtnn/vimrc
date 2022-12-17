
let g:loaded_vimfmt = 1

command! -bang -nargs=0 VimFmtRunTests :call vimfmt#run_tests()

augroup vimfmt
  autocmd!
  autocmd FileType vim :command! -buffer -bang -nargs=0 VimFmtBuffer :call vimfmt#buffer(<q-bang>, <q-args>)
augroup END
