
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

highlight Normal             gui=NONE           guifg=#e0e0e0 guibg=#0c0c0c
highlight EndOfBuffer        gui=NONE           guifg=#111111 guibg=#0d0d0d

highlight WildMenu           gui=NONE           guifg=#ffffff guibg=#1a1a1a
highlight TabLineSel         gui=NONE           guifg=#ffffff guibg=#1a1a1a
highlight TabLine            gui=NONE           guifg=#666666 guibg=#1a1a1a
highlight TabLineFill        gui=NONE           guifg=#666666 guibg=#1a1a1a
highlight StatusLine         gui=NONE           guifg=#999999 guibg=#1a1a1a
highlight StatusLineTerm     gui=NONE           guifg=#999999 guibg=#1a1a1a
highlight StatusLineNC       gui=NONE           guifg=#555555 guibg=#1a1a1a
highlight StatusLineTermNC   gui=NONE           guifg=#555555 guibg=#1a1a1a
highlight VertSplit          gui=NONE           guifg=#1a1a1a guibg=#1a1a1a

highlight ColorColumn        gui=NONE           guifg=NONE    guibg=#f7f7f7
highlight CursorLine         gui=NONE           guifg=NONE    guibg=#f7f7f7
highlight CursorColumn       gui=NONE           guifg=NONE    guibg=#f7f7f7

highlight Pmenu              gui=NONE           guifg=#555555 guibg=#232323
highlight PmenuSel           gui=UNDERLINE      guifg=NONE    guibg=#232323
highlight PmenuSbar          gui=NONE           guifg=NONE    guibg=#0e0e0e
highlight PmenuThumb         gui=NONE           guifg=NONE    guibg=#3e3e3e

highlight Folded             gui=UNDERLINE      guifg=#555555 guibg=NONE
highlight FoldColumn         gui=NONE           guifg=#777777 guibg=#181818
highlight LineNr             gui=NONE           guifg=#555555 guibg=#181818
highlight CursorLineNr       gui=NONE           guifg=#666666 guibg=#181818

highlight QuickFixLine       gui=NONE           guifg=#666666 guibg=#cccc22
highlight Search             gui=NONE           guifg=#000000 guibg=#777711
highlight IncSearch          gui=NONE           guifg=#000000 guibg=#777711
highlight Cursor             gui=NONE           guifg=#000000 guibg=#ffffff
highlight Visual             gui=NONE           guifg=NONE    guibg=#113311

highlight Comment            gui=NONE           guifg=#555555 guibg=NONE
highlight SpecialKey         gui=NONE           guifg=#552255 guibg=NONE
highlight NonText            gui=NONE           guifg=#cccccc guibg=NONE

highlight Directory          gui=NONE           guifg=#b6b628 guibg=NONE
highlight Title              gui=NONE           guifg=#b6b628 guibg=NONE
highlight Keyword            gui=NONE           guifg=#b6b628 guibg=NONE
highlight Type               gui=NONE           guifg=#b6b628 guibg=NONE
highlight Identifier         gui=NONE           guifg=#55bb55 guibg=NONE
highlight Special            gui=NONE           guifg=#8888d9 guibg=NONE
highlight Statement          gui=NONE           guifg=#cc44cc guibg=NONE
highlight PreProc            gui=NONE           guifg=#44cccc guibg=NONE
highlight String             gui=NONE           guifg=#55bb55 guibg=NONE
highlight Constant           gui=NONE           guifg=#8888d9 guibg=NONE

highlight MatchParen         gui=UNDERLINE      guifg=NONE    guibg=NONE

highlight link Identifier    DiffAdd
highlight link Special       DiffDelete
highlight      DiffChange    gui=BOLD           guifg=#993399 guibg=NONE
highlight      DiffText      gui=BOLD,UNDERLINE guifg=#993399 guibg=NONE

if has('tabsidebar')
    highlight TabSideBarSel  gui=NONE           guifg=#999999 guibg=#232323
    highlight TabSideBar     gui=NONE           guifg=#555555 guibg=#1a1a1a
    highlight TabSideBarFill gui=NONE           guifg=#999999 guibg=#1a1a1a
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

