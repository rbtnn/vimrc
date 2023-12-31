function! s:colorscheme(colors_name) abort
    if a:colors_name == 'palenight'
        colorscheme palenight
        highlight!       TabSideBar               guifg=#777777 guibg=#292d3e gui=NONE cterm=NONE
        highlight!       TabSideBarFill           guifg=NONE    guibg=#292d3e gui=NONE cterm=NONE
        highlight!       TabSideBarNerdFont       guifg=#82b1ff guibg=#292d3e gui=NONE cterm=NONE
        highlight!       TabSideBarCurTab         guifg=#777777 guibg=#393d4e gui=NONE cterm=NONE
        highlight!       TabSideBarCurTabSel      guifg=#bcbcbc guibg=#393d4e gui=BOLD cterm=NONE
        highlight!       TabSideBarCurrNerdFont   guifg=#82b1ff guibg=#393d4e gui=NONE cterm=NONE
        highlight!       CursorLine                             guibg=NONE
        highlight!       VimrcDevPopupBorder      guifg=#ffcb6b guibg=NONE    gui=NONE cterm=NONE
        let g:lightline = { 'colorscheme': 'palenight' }
    elseif a:colors_name == 'molokai'
        colorscheme molokai
        highlight!       TabSideBar               guifg=#777777 guibg=#1b1d1e gui=NONE cterm=NONE
        highlight!       TabSideBarFill           guifg=NONE    guibg=#1b1d1e gui=NONE cterm=NONE
        highlight!       TabSideBarNerdFont       guifg=#a6e22e guibg=#1b1d1e gui=NONE cterm=NONE
        highlight!       TabSideBarCurTab         guifg=#777777 guibg=#3b3d3e gui=NONE cterm=NONE
        highlight!       TabSideBarCurTabSel      guifg=#bcbcbc guibg=#3b3d3e gui=BOLD cterm=NONE
        highlight!       TabSideBarCurrNerdFont   guifg=#a6e22e guibg=#3b3d3e gui=NONE cterm=NONE
        highlight!       Cursor                   guifg=#ffffff guibg=#d700d7
        highlight!       CursorLine                             guibg=NONE
        highlight!       VimrcDevPopupBorder      guifg=#a6e22e guibg=NONE    gui=NONE cterm=NONE
        highlight!       Special                                              gui=NONE
        highlight!       Macro                                                gui=NONE
        highlight!       StorageClass                                         gui=NONE
        highlight! link  DiffAdd                  Identifier
        highlight! link  DiffDelete               Special
        highlight!       DiffText                 gui=bold
        let g:lightline = { 'colorscheme': 'molokai' }
    elseif a:colors_name == 'deep-space'
        colorscheme deep-space
        highlight!       TabSideBar               guifg=#777777 guibg=#1b202a gui=NONE cterm=NONE
        highlight!       TabSideBarFill           guifg=NONE    guibg=#1b202a gui=NONE cterm=NONE
        highlight!       TabSideBarNerdFont       guifg=#a6e22e guibg=#1b202a gui=NONE cterm=NONE
        highlight!       TabSideBarCurTab         guifg=#999999 guibg=#406ca3 gui=NONE cterm=NONE
        highlight!       TabSideBarCurTabSel      guifg=#bcbcbc guibg=#406ca3 gui=BOLD cterm=NONE
        highlight!       TabSideBarCurrNerdFont   guifg=#a6e22e guibg=#406ca3 gui=NONE cterm=NONE
        highlight!       VimrcDevPopupBorder      guifg=#a6e22e guibg=NONE    gui=NONE cterm=NONE
    elseif a:colors_name == 'github'
        let g:github_colors_soft = 0
        set background=light
        colorscheme github
        highlight!       TabSideBar               guifg=#777777 guibg=#2b2d2e gui=NONE cterm=NONE
        highlight!       TabSideBarFill           guifg=NONE    guibg=#2b2d2e gui=NONE cterm=NONE
        highlight!       TabSideBarSel            guifg=#bcbcbc guibg=#2b2d2e gui=NONE cterm=NONE
        highlight!       TabSideBarModified       guifg=#ff6666 guibg=#2b2d2e gui=BOLD cterm=NONE
        highlight!       Comment                  guifg=#bbbbbb guibg=NONE
        highlight!       Error                    guifg=#d73a49 guibg=NONE
        highlight! link  VimrcDevPopupBorder      Question
        let g:lightline = { 'colorscheme': 'github' }
    endif

    highlight! CursorIM                 guifg=NONE    guibg=#d70000

    if exists('g:loaded_parenmatch')
        let g:parenmatch_highlight = 0
        highlight! link  ParenMatch  MatchParen
    endif
    if exists('g:loaded_lightline')
        call lightline#enable()
    endif
endfunction

call s:colorscheme('palenight')
