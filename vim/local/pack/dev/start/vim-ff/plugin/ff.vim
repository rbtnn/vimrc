
let g:loaded_ff = 1

if !has('nvim')
	command! -bang -nargs=0 FF       :call ff#main(<q-bang>)
endif

augroup ff-mrw
	autocmd!
	autocmd BufWritePost         * :call ff#mrw_bufwritepost()
augroup END
