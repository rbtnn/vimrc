if has('vim_starting')
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTab         guifg=#777777 guibg=#3b3d3e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTabSel      guifg=#bcbcbc guibg=#3b3d3e gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       Cursor                   guifg=#ffffff guibg=#d700d7
        \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
        \ | highlight!       VimrcDevPopupBorder      guifg=#a6e22e guibg=NONE    gui=NONE cterm=NONE
        \ | highlight!       Special                                              gui=NONE
        \ | highlight!       Macro                                                gui=NONE
        \ | highlight!       StorageClass                                         gui=NONE
        \ | highlight! link  DiffAdd                  Identifier
        \ | highlight! link  DiffDelete               Special
        \ | highlight!       DiffText                 gui=bold
    colorscheme molokai
endif
