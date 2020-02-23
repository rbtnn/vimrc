
scriptencoding utf-8

function! CargoComp(ArgLead, CmdLine, CursorPos) abort
    return filter([
        \ 'build', 'check', 'clean', 'run', 'test', 'fmt'
        \ ], { i,x -> x =~# ('^' .. a:ArgLead) })
endfunction

function! FileTypeRust() abort
    command! -buffer -nargs=* -complete=customlist,CargoComp   Cargo  :terminal cargo <args>
endfunction

augroup vimrc_rust
    autocmd!
    autocmd FileType        rust :call FileTypeRust()
augroup END


