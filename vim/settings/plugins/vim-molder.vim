let g:molder_show_hidden = 1
autocmd vimrc-plugins FileType       molder
    \ :nnoremap <buffer> h  <plug>(molder-up)
    \ |nnoremap <buffer> l  <plug>(molder-open)
    \ |nnoremap <buffer> t  <Cmd>call term_start(&shell, { 'cwd': b:molder_dir, })<cr>
