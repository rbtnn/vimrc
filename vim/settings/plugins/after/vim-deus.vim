if has('vim_starting')
    "let g:lightline = { 'colorscheme': 'deus' }
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarSel            guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarLabel          guifg=#fe8019 guibg=#2b2d2e gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarModified       guifg=#ff6666 guibg=#2b2d2e gui=BOLD cterm=NONE
        \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
        \ | highlight! link  LsFilesPopupBorder       deusOrange
        \ | highlight! link  StatusLine               deusOrange
        \ | highlight! link  StatusLineNC             deusBlue
        \ | highlight! link  StatusLineTerm           deusOrange
        \ | highlight! link  StatusLineTermNC         deusBlue
    let g:deus_italic = 0
    colorscheme deus
endif
