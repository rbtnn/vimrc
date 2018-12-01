
" nnoremap <nowait><space>     :<C-u>echo synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')<cr>

" TODO
" ColorColumn
" FoldColumn
" Question
" SpellBad
" SpellCap
" SpellLocal
" SpellRare

if has('gui_running') || 256 <= &t_Co
    let g:colors_name = 'amethyst'

    highlight! Cursor           guibg=#aaaaaa guifg=NONE    gui=NONE
    highlight! CursorLine       guibg=#211936 guifg=NONE    gui=NONE
    highlight! link CursorColumn     CursorLine
    highlight! link Visual           CursorLine
    highlight! link Folded           CursorLine

    highlight! MatchParen       guibg=NONE    guifg=#aaaaaa gui=NONE

    highlight! SignColumn       guibg=#000000 guifg=#000000 gui=NONE
    highlight! Terminal         guibg=#18101F guifg=#8558AB gui=NONE
    highlight! Normal           guibg=#18101F guifg=#8558AB gui=NONE
    highlight! NonText          guibg=#18101F guifg=#161620 gui=NONE
    highlight! WildMenu         guibg=#000000 guifg=#aaaaaa gui=NONE
    highlight! StatusLine       guibg=#000000 guifg=#888888 gui=NONE
    highlight! StatusLineNC     guibg=#000000 guifg=#000000 gui=NONE
    highlight! StatusLineTerm   guibg=#000000 guifg=#888888 gui=NONE
    highlight! StatusLineTermNC guibg=#000000 guifg=#000000 gui=NONE
    highlight! VertSplit        guibg=#000000 guifg=#000000 gui=NONE

    highlight! TabLine          guibg=#000000 guifg=#222222 gui=NONE
    highlight! TabLineSel       guibg=#181833 guifg=#555555 gui=NONE
    highlight! TabLineFill      guibg=#000000 guifg=#000000 gui=NONE

    highlight! link Pmenu       TabLine
    highlight! link PmenuThumb  TabLine
    highlight! PmenuSel         guibg=#181833 guifg=#0ccccc gui=NONE
    highlight! PmenuSbar        guibg=#0f0f0f guifg=#444444 gui=NONE

    if has('tabsidebar')
        highlight! link TabSideBar       TabLine
        highlight! link TabSideBarEven   TabLine
        highlight! link TabSideBarOdd    TabLine
        highlight! link TabSideBarSel    TabLineSel
        highlight! link TabSideBarFill   TabLineFill
        highlight! link TabSideBarSelWin PmenuSel
    endif

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

    highlight! Ignore           guibg=#ff0000 guifg=#aaaaaa gui=NONE
    highlight! Search           guibg=NONE    guifg=#00cc00 gui=UNDERLINE
    highlight! LineNr           guibg=#000000 guifg=#333333 gui=NONE
    highlight! CursorLineNr     guibg=#000000 guifg=#00cc00 gui=NONE
    highlight! Title            guibg=NONE    guifg=#0ccccc gui=NONE

    highlight! Comment          guibg=NONE    guifg=#555555 gui=NONE
    highlight! SpecialKey       guibg=NONE    guifg=#222222 gui=NONE

    highlight! Statement        guibg=NONE    guifg=#646B21 gui=NONE

    highlight! Function         guibg=NONE    guifg=#8558AB gui=NONE
    highlight! Identifier       guibg=NONE    guifg=#8558AB gui=NONE
    highlight! Operator         guibg=NONE    guifg=#8558AB gui=NONE
    highlight! Special          guibg=NONE    guifg=#8558AB gui=NONE
    highlight! Directory        guibg=NONE    guifg=#8558AB gui=NONE
    highlight! Delimiter        guibg=NONE    guifg=#8558AB gui=NONE
    highlight! Type             guibg=NONE    guifg=#8558AB gui=NONE
    highlight! Structure        guibg=NONE    guifg=#8558AB gui=NONE

    highlight! PreProc          guibg=NONE    guifg=#326B47 gui=NONE
    highlight! Constant         guibg=NONE    guifg=#326B47 gui=NONE
    highlight! String           guibg=NONE    guifg=#326B47 gui=NONE

    highlight! Todo             guibg=NONE    guifg=#7777ff gui=BOLD
    highlight! ModeMsg          guibg=NONE    guifg=#77ff77 gui=NONE

endif

