
let g:loaded_f = 1

command! -complete=dir -nargs=* F    :call f#open(<q-args>)

augroup f
	autocmd!
	autocmd WinLeave *  :call f#close()
	autocmd FileType f  :nnoremap <buffer><silent><cr>      :<C-u>call f#select_file(getline('.'))<cr>
	autocmd FileType f  :nnoremap <buffer><silent><space>   :<C-u>call f#select_file(getline('.'))<cr>
	autocmd FileType f  :nnoremap <buffer><silent><esc>     :<C-u>call f#close()<cr>
	autocmd FileType f  :nnoremap <buffer><silent>d         :<C-u>call f#git_diff()<cr>
	autocmd FileType f  :nnoremap <buffer><silent>t         :<C-u>call f#terminal()<cr>
	autocmd FileType f  :nnoremap <buffer><silent>e         :<C-u>call f#explorer()<cr>
	autocmd FileType f  :nnoremap <buffer><silent>s         :<C-u>call f#search()<cr>
	autocmd FileType f  :nnoremap <buffer><silent>h         :<C-u>call f#updir()<cr>
	autocmd FileType f  :nnoremap <buffer><silent>l         :<C-u>call f#select_file(getline('.'))<cr>
	autocmd FileType f  :nnoremap <buffer><silent>c         :<C-u>call f#change_dir()<cr>
	autocmd FileType f  :nnoremap <buffer><silent>~         :<C-u>call f#open('~')<cr>
	autocmd FileType f  :nnoremap <buffer><silent>?         :<C-u>call f#help()<cr>
	autocmd FileType f  :nnoremap <buffer><silent><C-o>     <nop>
	autocmd FileType f  :nnoremap <buffer><silent><C-i>     <nop>
augroup END

