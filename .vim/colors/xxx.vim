
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

highlight! Normal             gui=NONE           guifg=#e0e0e0 guibg=#101b1f
highlight! Terminal           gui=NONE           guifg=#e0e0e0 guibg=#101b1f
highlight! EndOfBuffer        gui=NONE           guifg=#223c45 guibg=#101b1f

highlight! Comment            gui=NONE           guifg=#547898 guibg=NONE
highlight! SpecialKey         gui=NONE           guifg=#2c3e4f guibg=NONE

highlight! Pmenu              gui=NONE           guifg=#888888 guibg=#223c45
highlight! PmenuSel           gui=BOLD           guifg=#e0e0e0 guibg=#223c45
highlight! PmenuSbar          gui=NONE           guifg=NONE    guibg=#223c45
highlight! PmenuThumb         gui=NONE           guifg=NONE    guibg=#eeeeee

highlight! TabLine            gui=NONE           guifg=#88889c guibg=#000000
highlight! TabLineSel         gui=UNDERLINE      guifg=#88889c guibg=#000000
highlight! TabLineFill        gui=NONE           guifg=#88889c guibg=#000000

highlight! StatusLine         gui=NONE           guifg=#88889c guibg=#203842
highlight! StatusLineTerm     gui=NONE           guifg=#88889c guibg=#203842
highlight! StatusLineNC       gui=NONE           guifg=#88889d guibg=#203842
highlight! StatusLineTermNC   gui=NONE           guifg=#88889d guibg=#203842
highlight! VertSplit          gui=NONE           guifg=#203842 guibg=#203842

highlight! WildMenu           gui=UNDERLINE      guifg=#e0e0e0 guibg=#080924

highlight! ErrorMsg           gui=NONE           guifg=#ff0000 guibg=NONE
highlight! WarningMsg         gui=NONE           guifg=#ffff00 guibg=NONE

highlight! Folded             gui=UNDERLINE      guifg=#555555 guibg=NONE
highlight! FoldColumn         gui=NONE           guifg=#20313c guibg=#20313c

highlight!      LineNr        gui=NONE           guifg=#67677b guibg=#1c242c
highlight!      SignColumn    gui=NONE           guifg=#67677b guibg=#1c242c

highlight!      CursorLineNr  gui=NONE           guifg=#666666 guibg=#181818
highlight!      CursorLine    gui=NONE           guifg=NONE    guibg=#181818
highlight!      CursorColumn  gui=NONE           guifg=NONE    guibg=#181818

highlight! ColorColumn        gui=NONE           guifg=NONE    guibg=#25303b

highlight! link LineNrAbove   LineNr
highlight! link LineNrBelow   LineNr

highlight!      MatchParen    gui=UNDERLINE,BOLD guifg=#ffff00 guibg=NONE

highlight! QuickFixLine       gui=NONE           guifg=NONE    guibg=NONE

highlight! Search             gui=BOLD           guifg=NONE    guibg=#224544
highlight! IncSearch          gui=BOLD           guifg=NONE    guibg=#366f6c

highlight! Visual             gui=NONE           guifg=NONE    guibg=#366f6c

highlight! Cursor             gui=NONE           guifg=#000000 guibg=#ffffff
highlight! CursorIM           gui=NONE           guifg=#000000 guibg=#aa0000

highlight! NonText            gui=NONE           guifg=#aa6666 guibg=NONE
highlight! Conceal            gui=NONE           guifg=#aa6666 guibg=NONE
highlight! Ignore             gui=NONE           guifg=#aa6666 guibg=NONE

highlight! Directory          gui=NONE           guifg=#b6b628 guibg=NONE
highlight! Title              gui=NONE           guifg=#b6b628 guibg=NONE
highlight! Keyword            gui=NONE           guifg=#b6b628 guibg=NONE
highlight! Type               gui=NONE           guifg=#b6b628 guibg=NONE
highlight! Identifier         gui=NONE           guifg=#55bb55 guibg=NONE
highlight! Special            gui=NONE           guifg=#8c8cff guibg=NONE
highlight! PreProc            gui=NONE           guifg=#4787a9 guibg=NONE
highlight! Statement          gui=NONE           guifg=#cc44cc guibg=NONE
highlight! String             gui=NONE           guifg=#55bb55 guibg=NONE
highlight! Constant           gui=NONE           guifg=#8c8cff guibg=NONE

highlight! DiffAdd            gui=NONE           guifg=#55bb55 guibg=NONE
highlight! DiffDelete         gui=NONE           guifg=#ff6c6c guibg=NONE
highlight! DiffChange         gui=BOLD           guifg=#993399 guibg=NONE
highlight! DiffText           gui=BOLD,UNDERLINE guifg=#993399 guibg=NONE

highlight! link diffAdded     DiffAdd
highlight! link diffRemoved   DiffDelete

if has('tabsidebar')
    highlight! link TabSideBar         Pmenu
    highlight! link TabSideBarSel      PmenuSel
    highlight!      TabSideBarFill     gui=NONE           guifg=#0f1b1f guibg=#203842
endif

if v:false
    function! StatusLine() abort
        let syn_id = synID(line('.'), col('.'), 1)
        let name_t = syn_id->synIDattr('name')
        if empty(name_t)
            let name_t = 'Normal'
        endif

        let trans_syn_id = syn_id->synIDtrans()
        let trans_name_t = trans_syn_id->synIDattr('name')
        if empty(trans_name_t)
            let trans_name_t = 'Normal'
        endif

        return (((trans_name_t != name_t) && !empty(name_t)) ? (name_t .. ' -> ') : '')
            \ .. trim(execute(printf('highlight %s', trans_name_t)))
    endfunction
    set statusline=%!StatusLine()
endif

