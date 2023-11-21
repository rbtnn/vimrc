if has('vim_starting')
    "let g:lightline = { 'colorscheme': 'moonfly', }
    autocmd vimrc-plugins ColorScheme      *
        \ : highlight!       TabSideBar               guifg=#777777 guibg=#121215 gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTab         guifg=#777777 guibg=#222225 gui=NONE cterm=NONE
        \ | highlight!       TabSideBarCurTabSel      guifg=#bcbcbc guibg=#222225 gui=BOLD cterm=NONE
        \ | highlight!       TabSideBarFill           guifg=NONE    guibg=#121215 gui=NONE cterm=NONE
        \ | highlight!       CursorIM                 guifg=NONE    guibg=#d70000
        \ | highlight!       VimrcDevPopupBorder      guifg=#a6e22e guibg=NONE    gui=NONE cterm=NONE
        \ | highlight!       SpecialKey               guifg=#04428f
        \ | highlight!       Comment                  guifg=#444444               gui=NONE
    colorscheme moonfly
endif
