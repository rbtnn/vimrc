
augroup vimrc-autocmds
    autocmd!
    " Delete unused commands, because it's an obstacle on cmdline-completion.
    autocmd CmdlineEnter     *
        \ : for s:cmdname in ['MANPAGER', 'Man', 'Tutor', 'VimFoldh', 'TextobjStringDefaultKeyMappings']
        \ |     execute printf('silent! delcommand %s', s:cmdname)
        \ | endfor
        \ | unlet s:cmdname
    autocmd FileType help :setlocal colorcolumn=78
augroup END

