if has('vim_starting')
    "let g:lightline = { 'colorscheme': 'github' }
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarSel            guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
        \ | highlight!       TabSideBarLabel          guifg=#fe8019 guibg=#2b2d2e gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarModified       guifg=#ff6666 guibg=#2b2d2e gui=BOLD cterm=NONE
        \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
        \ | highlight!       Comment                  guifg=#bbbbbb guibg=NONE
        \ | highlight!       Error                    guifg=#d73a49 guibg=NONE
        \ | highlight! link  LsFilesPopupBorder       Question
    set background=light
    let g:github_colors_soft = 0
    colorscheme github
endif
