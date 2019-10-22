
if has('vimscript-4')
    scriptversion 4
else
    finish
endif
scriptencoding utf-8

function! CargoComp(ArgLead, CmdLine, CursorPos) abort
    return filter([
        \ 'build', 'check', 'clean', 'run', 'test', 'fmt'
        \ ], { i,x -> x =~# ('^' .. a:ArgLead) })
endfunction

function! FileTypeRust() abort
    command! -buffer -nargs=* -complete=customlist,CargoComp   Cargo  :terminal cargo <args>
    nnoremap <silent><nowait><buffer>s  :<C-u>Cargo run<cr>
endfunction

augroup vimrc_rust
    autocmd!
    autocmd FileType        rust :call FileTypeRust()
augroup END


