
let s:flag = v:false

if has('gui_running')
    let s:flag = v:true
elseif has('termguicolors')
    if &termguicolors
        let s:flag = v:true
    endif
endif

if !s:flag
    finish
endif

highlight clear

if exists('syntax_on')
    syntax reset
endif

let g:colors_name = substitute(fnamemodify(expand('<sfile>'), ':t'), '.vim', '', '')

highlight Normal             gui=NONE           guifg=#e0e0e0 guibg=#203b46
highlight EndOfBuffer        gui=NONE           guifg=#304b56 guibg=#203b46

highlight Pmenu              gui=NONE           guifg=#555555 guibg=#1a2530
highlight PmenuSel           gui=UNDERLINE      guifg=#e0e0e0 guibg=#1a2530
highlight PmenuSbar          gui=NONE           guifg=NONE    guibg=#1a2530
highlight PmenuThumb         gui=NONE           guifg=NONE    guibg=#eeeeee

highlight TabLine            gui=NONE           guifg=#565666 guibg=#000000
highlight TabLineSel         gui=UNDERLINE      guifg=#565666 guibg=#000000
highlight TabLineFill        gui=NONE           guifg=#565666 guibg=#000000

highlight StatusLine         gui=NONE           guifg=#565666 guibg=#000000
highlight StatusLineTerm     gui=NONE           guifg=#565666 guibg=#000000
highlight StatusLineNC       gui=NONE           guifg=#555565 guibg=#000000
highlight StatusLineTermNC   gui=NONE           guifg=#555565 guibg=#000000
highlight VertSplit          gui=NONE           guifg=#000000 guibg=#000000

highlight WildMenu           gui=UNDERLINE      guifg=#e0e0e0 guibg=#080924

highlight ErrorMsg           gui=NONE           guifg=#ff0000 guibg=NONE
highlight WarningMsg         gui=NONE           guifg=#ffff00 guibg=NONE

highlight ColorColumn        gui=NONE           guifg=NONE    guibg=#25303b
highlight CursorColumn       gui=NONE           guifg=NONE    guibg=#25303b
highlight CursorLine         gui=NONE           guifg=NONE    guibg=#25303b
highlight Visual             gui=NONE           guifg=NONE    guibg=#75808b

highlight Folded             gui=UNDERLINE      guifg=#555555 guibg=NONE
highlight FoldColumn         gui=NONE           guifg=#20313c guibg=#20313c

highlight      LineNr        gui=NONE           guifg=#555555 guibg=#181818
highlight      CursorLineNr  gui=NONE           guifg=#666666 guibg=#181818
highlight link LineNrAbove   LineNr
highlight link LineNrBelow   LineNr

highlight      MatchParen    gui=UNDERLINE,BOLD guifg=#ffff00 guibg=NONE

let g:parenmatch_highlight = 0
highlight link ParenMatch    MatchParen

highlight QuickFixLine       gui=UNDERLINE,BOLD guifg=NONE    guibg=NONE
highlight Search             gui=UNDERLINE,BOLD guifg=#ffff00 guibg=NONE
highlight IncSearch          gui=UNDERLINE,BOLD guifg=#ffff00 guibg=NONE

highlight Cursor             gui=NONE           guifg=#000000 guibg=#e0e0e0
highlight CursorIM           gui=NONE           guifg=#000000 guibg=#aa0000

highlight Comment            gui=NONE           guifg=#888888 guibg=NONE
highlight SpecialKey         gui=NONE           guifg=#aa6666 guibg=NONE
highlight NonText            gui=NONE           guifg=#aa6666 guibg=NONE
highlight Conceal            gui=NONE           guifg=#aa6666 guibg=NONE
highlight Ignore             gui=NONE           guifg=#aa6666 guibg=NONE

highlight Directory          gui=NONE           guifg=#b6b628 guibg=NONE
highlight Title              gui=NONE           guifg=#b6b628 guibg=NONE
highlight Keyword            gui=NONE           guifg=#b6b628 guibg=NONE
highlight Type               gui=NONE           guifg=#b6b628 guibg=NONE
highlight Identifier         gui=NONE           guifg=#55bb55 guibg=NONE
highlight Special            gui=NONE           guifg=#8c8cff guibg=NONE
highlight Statement          gui=NONE           guifg=#cc44cc guibg=NONE
highlight PreProc            gui=NONE           guifg=#44cccc guibg=NONE
highlight String             gui=NONE           guifg=#55bb55 guibg=NONE
highlight Constant           gui=NONE           guifg=#8c8cff guibg=NONE

highlight link Identifier    DiffAdd
highlight link Special       DiffDelete
highlight              DiffChange    gui=BOLD           guifg=#993399 guibg=NONE
highlight              DiffText      gui=BOLD,UNDERLINE guifg=#993399 guibg=NONE

if has('tabsidebar')
    highlight TabSideBarTitleSel gui=BOLD           guifg=#e0e0e0 guibg=#007777
    highlight TabSideBarTitle    gui=NONE           guifg=#a0a0a0 guibg=#004444
    highlight TabSideBarSel      gui=NONE           guifg=#e0e0e0 guibg=#40415c
    highlight TabSideBar         gui=NONE           guifg=#888888 guibg=#40415c
    highlight TabSideBarFill     gui=NONE           guifg=#000000 guibg=#000000
endif

if v:false
    function! StatusLine() abort
        let syn_id = synID(line('.'), col('.'), 1)
        let trans_id = syn_id->synIDtrans()
        let name_t = trans_id->synIDattr('name')
        if empty(name_t)
            let name_t = 'Normal'
        endif
        return trim(execute(printf('highlight %s', name_t)))
    endfunction
endif

