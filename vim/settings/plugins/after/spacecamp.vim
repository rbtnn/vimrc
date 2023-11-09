if has('vim_starting')
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#777777 guibg=#181818 gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTab         guifg=#777777 guibg=#1e1e1e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTabSel      guifg=#bcbcbc guibg=#1e1e1e gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#181818 gui=NONE cterm=NONE
        \ | highlight!       Cursor                   guifg=#000000 guibg=#00d700
        \ | highlight!       CursorIM                 guifg=#000000 guibg=#d70000
        \ | highlight! link  VimrcDevPopupBorder      Identifier
        \ | highlight! link  diffAdded                DiffAdd
        \ | highlight! link  diffRemoved              DiffDelete
        \ | highlight! link  diffChanged              DiffText
    colorscheme spacecamp
endif

