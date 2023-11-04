if has('vim_starting')
    "let g:lightline = { 'colorscheme': 'dogrun', }
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#757aa5 guibg=#2a2c3f gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTab         guifg=#757aa5 guibg=#929be5 gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTabSel      guifg=#222433 guibg=#929be5 gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#2a2c3f gui=NONE cterm=NONE
        \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
        \ | highlight!       VimrcDevPopupBorder      guifg=#b871b8 guibg=NONE    gui=NONE cterm=NONE
    colorscheme dogrun
endif
