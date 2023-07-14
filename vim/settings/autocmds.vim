
let s:delcmds = [
    \ 'MANPAGER', 'Man', 'Tutor', 'VimFoldh', 'TextobjStringDefaultKeyMappings',
    \ 'CurrentLineWhitespaceOff', 'CurrentLineWhitespaceOn', 'DisableStripWhitespaceOnSave',
    \ 'DisableWhitespace', 'EnableStripWhitespaceOnSave', 'EnableWhitespace',
    \ 'NextTrailingWhitespace', 'PrevTrailingWhitespace', 'StripWhitespace',
    \ 'StripWhitespaceOnChangedLines', 'ToggleStripWhitespaceOnSave', 'ToggleWhitespace',
    \ ]

augroup vimrc-autocmds
    autocmd!
    " Delete unused commands, because it's an obstacle on cmdline-completion.
    autocmd CmdlineEnter     *
        \ : for s:cmdname in s:delcmds
        \ |     execute printf('silent! delcommand %s', s:cmdname)
        \ | endfor
        \ | unlet s:cmdname
    autocmd InsertEnter     *
        \ : set noimdisable
    autocmd InsertLeave     *
        \ : set imdisable
    autocmd FileType help :setlocal colorcolumn=78
augroup END

