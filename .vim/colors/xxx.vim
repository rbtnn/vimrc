
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

highlight Normal             gui=NONE           guifg=#e0e0e0 guibg=#26313c
highlight EndOfBuffer        gui=NONE           guifg=#1a2530 guibg=#1a2530

highlight Pmenu              gui=NONE           guifg=#555555 guibg=#0a1520
highlight PmenuSel           gui=UNDERLINE      guifg=#e0e0e0 guibg=#0a1520
highlight PmenuSbar          gui=NONE           guifg=NONE    guibg=#0a1520
highlight PmenuThumb         gui=NONE           guifg=NONE    guibg=#eeeeee

highlight ErrorMsg           gui=NONE           guifg=#ff0000 guibg=NONE
highlight WarningMsg         gui=NONE           guifg=#ffff00 guibg=NONE

highlight TabLineSel         gui=UNDERLINE      guifg=#e0e0e0 guibg=#080924
highlight TabLine            gui=NONE           guifg=#666666 guibg=#080924
highlight TabLineFill        gui=NONE           guifg=#666666 guibg=#080924

highlight WildMenu           gui=UNDERLINE      guifg=#e0e0e0 guibg=#080924
highlight StatusLine         gui=NONE           guifg=#999999 guibg=#080924
highlight StatusLineTerm     gui=NONE           guifg=#999999 guibg=#080924
highlight StatusLineNC       gui=NONE           guifg=#555555 guibg=#080924
highlight StatusLineTermNC   gui=NONE           guifg=#555555 guibg=#080924
highlight VertSplit          gui=NONE           guifg=#080924 guibg=#080924

highlight ColorColumn        gui=NONE           guifg=NONE    guibg=#25303b
highlight CursorColumn       gui=NONE           guifg=NONE    guibg=#25303b
highlight CursorLine         gui=NONE           guifg=NONE    guibg=#25303b
highlight Visual             gui=NONE           guifg=NONE    guibg=#45505b

highlight Folded             gui=UNDERLINE      guifg=#555555 guibg=NONE
highlight FoldColumn         gui=NONE           guifg=#20313c guibg=#20313c
highlight LineNr             gui=NONE           guifg=#555555 guibg=#181818
highlight CursorLineNr       gui=NONE           guifg=#666666 guibg=#181818

highlight MatchParen         gui=UNDERLINE,BOLD guifg=NONE    guibg=NONE
highlight QuickFixLine       gui=UNDERLINE,BOLD guifg=NONE    guibg=NONE
highlight Search             gui=UNDERLINE,BOLD guifg=NONE    guibg=NONE
highlight IncSearch          gui=UNDERLINE,BOLD guifg=#e0e0e0 guibg=NONE

highlight Cursor             gui=NONE           guifg=#000000 guibg=#e0e0e0
highlight CursorIM           gui=NONE           guifg=#000000 guibg=#aa0000

highlight Comment            gui=NONE           guifg=#888888 guibg=NONE
highlight SpecialKey         gui=NONE           guifg=#aa44aa guibg=NONE
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

highlight link Identifier    DiffAdd
highlight link Special       DiffDelete
highlight      DiffChange    gui=BOLD           guifg=#993399 guibg=NONE
highlight      DiffText      gui=BOLD,UNDERLINE guifg=#993399 guibg=NONE

if has('tabsidebar')
    highlight TabSideBarTitle gui=BOLD      guifg=#e0e0e0 guibg=#007777
    highlight TabSideBarSel   gui=NONE      guifg=#e0e0e0 guibg=#080924
    highlight TabSideBar      gui=NONE      guifg=#555555 guibg=#080924
    highlight TabSideBarFill  gui=NONE      guifg=#080924 guibg=#080924
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

