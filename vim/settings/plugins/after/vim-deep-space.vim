if has('vim_starting')
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#777777 guibg=#1b202a gui=NONE cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#1b202a gui=NONE cterm=NONE
        \ | highlight!       TabSideBarNerdFont       guifg=#a6e22e guibg=#1b202a gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTab         guifg=#999999 guibg=#406ca3 gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTabSel      guifg=#bcbcbc guibg=#406ca3 gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarCurrNerdFont   guifg=#a6e22e guibg=#406ca3 gui=NONE cterm=NONE
        \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
        \ | highlight!       VimrcDevPopupBorder      guifg=#a6e22e guibg=NONE    gui=NONE cterm=NONE
    colorscheme deep-space
endif
