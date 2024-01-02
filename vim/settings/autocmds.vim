
let s:delcmds = [
    \ 'MANPAGER', 'Man', 'Tutor', 'VimFoldh',
    \ 'TextobjBetweenDefaultKeyMappings', 'TextobjParameterDefaultKeyMappings', 'TextobjStringDefaultKeyMappings',
    \ 'CurrentLineWhitespaceOff', 'CurrentLineWhitespaceOn', 'DisableStripWhitespaceOnSave',
    \ 'DisableWhitespace', 'EnableStripWhitespaceOnSave', 'EnableWhitespace',
    \ 'NextTrailingWhitespace', 'PrevTrailingWhitespace', 'StripWhitespace',
    \ 'StripWhitespaceOnChangedLines', 'ToggleStripWhitespaceOnSave', 'ToggleWhitespace',
    \ 'TextobjLineDefaultKeyMappings', 'VimTweakDisableCaption', 'VimTweakDisableMaximize', 'VimTweakDisableTopMost',
    \ 'VimTweakEnableCaption', 'VimTweakEnableMaximize', 'VimTweakEnableTopMost',
    \ ]

augroup vimrc-plugins
    autocmd!
augroup END

augroup vimrc-autocmds
    autocmd!
    " Delete unused commands, because it's an obstacle on cmdline-completion.
    autocmd CmdlineEnter *
        \ : for s:cmdname in s:delcmds
        \ |     execute printf('silent! delcommand %s', s:cmdname)
        \ | endfor
        \ | unlet s:cmdname
    autocmd FileType help :setlocal colorcolumn=78
    autocmd CmdlineEnter *
        \ : if getcmdtype() == ':'
        \ |     set ignorecase
        \ | endif
    autocmd CmdlineLeave * :set noignorecase
augroup END

