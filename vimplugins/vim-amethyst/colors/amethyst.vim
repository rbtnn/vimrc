
"nnoremap <nowait><space>     :<C-u>echo synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')<cr>

" TODO
" ColorColumn
" CursorLineNr
" FoldColumn
" Question
" SpellBad
" SpellCap
" SpellLocal
" SpellRare

if has('gui_running') || 256 <= &t_Co
    highlight clear

    if exists('syntax_on')
        syntax reset
    endif

    let g:colors_name = 'amethyst'

    highlight! Cursor           guibg=#dddddd guifg=NONE    gui=NONE
    highlight! CursorLine       guibg=#393946 guifg=NONE    gui=NONE
    highlight! CursorColumn     guibg=#393946 guifg=NONE    gui=NONE

    highlight! MatchParen       guibg=NONE    guifg=#dddddd gui=NONE

    highlight! SignColumn       guibg=#030306 guifg=#101010 gui=NONE
    highlight! Terminal         guibg=#30303d guifg=#aaaaaa gui=NONE
    highlight! Normal           guibg=#30303d guifg=#aaaaaa gui=NONE
    highlight! NonText          guibg=#161620 guifg=#161620 gui=NONE
    highlight! WildMenu         guibg=#030306 guifg=#dddddd gui=NONE
    highlight! StatusLine       guibg=#030306 guifg=#888888 gui=NONE
    highlight! StatusLineNC     guibg=#030306 guifg=#1a1a1a gui=NONE
    highlight! StatusLineTerm   guibg=#030306 guifg=#888888 gui=NONE
    highlight! StatusLineTermNC guibg=#030306 guifg=#1a1a1a gui=NONE
    highlight! VertSplit        guibg=#030306 guifg=#030306 gui=NONE

    highlight! TabLine          guibg=#1a1a1a guifg=#555555 gui=NONE
    highlight! TabLineSel       guibg=#3f3f2f guifg=#dddddd gui=NONE
    highlight! TabLineFill      guibg=#030306 guifg=#101010 gui=NONE

    if has('tabsidebar')
        highlight! TabSideBarOdd    guibg=#171724 guifg=#555555 gui=NONE
        highlight! TabSideBarEven   guibg=#12121f guifg=#555555 gui=NONE
        highlight! TabSideBarSel    guibg=#30303d guifg=#aaaaaa gui=NONE
        highlight! TabSideBarFill   guibg=#030306 guifg=#030306 gui=NONE
    endif

    highlight! Pmenu            guibg=#0f0f0f guifg=#444444 gui=NONE
    highlight! PmenuSbar        guibg=#0f0f0f guifg=#444444 gui=NONE
    highlight! PmenuSel         guibg=#141414 guifg=#dddddd gui=NONE
    highlight! PmenuThumb       guibg=#0f0f0f guifg=#444444 gui=NONE

    highlight! Error            guibg=NONE    guifg=#ff0000 gui=NONE
    highlight! ErrorMsg         guibg=NONE    guifg=#ff0000 gui=NONE
    highlight! WarningMsg       guibg=NONE    guifg=#ffff00 gui=NONE
    highlight! MoreMsg          guibg=NONE    guifg=#00ff00 gui=NONE

    highlight! DiffAdd          guibg=NONE    guifg=#009f00 gui=NONE
    highlight! diffAdded        guibg=NONE    guifg=#009f00 gui=NONE
    highlight! DiffDelete       guibg=NONE    guifg=#9f0000 gui=NONE
    highlight! diffRemoved      guibg=NONE    guifg=#9f0000 gui=NONE
    highlight! DiffChange       guibg=NONE    guifg=NONE    gui=NONE
    highlight! DiffText         guibg=NONE    guifg=NONE    gui=NONE

    highlight! Ignore           guibg=#ff0000 guifg=#dddddd gui=NONE
    highlight! Search           guibg=NONE    guifg=#00cc00 gui=UNDERLINE
    highlight! LineNr           guibg=#161620 guifg=#555555 gui=NONE
    highlight! Title            guibg=NONE    guifg=#0ccccc gui=NONE

    highlight! Comment          guibg=NONE    guifg=#555555 gui=NONE
    highlight! Folded           guibg=#161620 guifg=#555555 gui=NONE
    highlight! SpecialKey       guibg=NONE    guifg=#222222 gui=NONE
    highlight! Visual           guibg=#4a4a55 guifg=NONE    gui=NONE

    highlight! Statement        guibg=NONE    guifg=#c9c999 gui=NONE

    highlight! Function         guibg=NONE    guifg=#9999c9 gui=NONE
    highlight! Identifier       guibg=NONE    guifg=#9999c9 gui=NONE
    highlight! Operator         guibg=NONE    guifg=#9999c9 gui=NONE
    highlight! Special          guibg=NONE    guifg=#9999c9 gui=NONE
    highlight! Directory        guibg=NONE    guifg=#9999c9 gui=NONE
    highlight! Delimiter        guibg=NONE    guifg=#9999c9 gui=NONE
    highlight! Type             guibg=NONE    guifg=#9999c9 gui=NONE
    highlight! Structure        guibg=NONE    guifg=#9999c9 gui=NONE

    highlight! PreProc          guibg=NONE    guifg=#c99999 gui=NONE
    highlight! Constant         guibg=NONE    guifg=#c99999 gui=NONE
    highlight! String           guibg=NONE    guifg=#c99999 gui=NONE

    highlight! Todo             guibg=NONE    guifg=#7777ff gui=BOLD
    highlight! ModeMsg          guibg=NONE    guifg=#77ff77 gui=NONE

endif

