if has('vim_starting')
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTab         guifg=#777777 guibg=#3b3d3e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTabSel      guifg=#bcbcbc guibg=#3b3d3e gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
        \ | highlight!       LsFilesPopupBorder       guifg=#3b3d3e guibg=NONE    gui=BOLD cterm=NONE
        \ | highlight!       Special                                              gui=NONE
        \ | highlight!       Macro                                                gui=NONE
        \ | highlight!       StorageClass                                         gui=NONE
        \ | highlight! link  DiffAdd                  Identifier
        \ | highlight! link  DiffDelete               Special
    colorscheme molokai
endif
