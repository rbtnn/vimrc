if has('vim_starting')
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarSel            guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarLabel          guifg=#fe8019 guibg=#2b2d2e gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarModified       guifg=#ff6666 guibg=#2b2d2e gui=BOLD cterm=NONE
        \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
        \ | highlight!       LsFilesPopupBorder       guifg=#a6e22e guibg=NONE    gui=BOLD cterm=NONE
        \ | highlight!       Special                                              gui=NONE
        \ | highlight!       Macro                                                gui=NONE
        \ | highlight!       StorageClass                                         gui=NONE
        \ | highlight! link  DiffAdd                  Identifier
        \ | highlight! link  DiffDelete               Special
    colorscheme molokai
endif
