
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

highlight Normal             gui=NONE           guifg=#e0e0e0 guibg=#15202b
highlight EndOfBuffer        gui=NONE           guifg=#25303b guibg=#15202b

highlight Pmenu              gui=NONE           guifg=#555555 guibg=#05101b
highlight PmenuSel           gui=UNDERLINE      guifg=#ffffff guibg=#05101b
highlight PmenuSbar          gui=NONE           guifg=NONE    guibg=#1a151a
highlight PmenuThumb         gui=NONE           guifg=NONE    guibg=#000000

highlight ErrorMsg           gui=NONE           guifg=#ff0000 guibg=NONE
highlight WarningMsg         gui=NONE           guifg=#ffff00 guibg=NONE

highlight TabLineSel         gui=NONE           guifg=#ffffff guibg=#05101b
highlight TabLine            gui=NONE           guifg=#666666 guibg=#05101b
highlight TabLineFill        gui=NONE           guifg=#666666 guibg=#05101b

highlight WildMenu           gui=NONE           guifg=#ffffff guibg=#1c2732
highlight StatusLine         gui=NONE           guifg=#999999 guibg=#1c2732
highlight StatusLineTerm     gui=NONE           guifg=#999999 guibg=#1c2732
highlight StatusLineNC       gui=NONE           guifg=#555555 guibg=#1c2732
highlight StatusLineTermNC   gui=NONE           guifg=#555555 guibg=#1c2732
highlight VertSplit          gui=NONE           guifg=#1c2732 guibg=#1c2732

highlight ColorColumn        gui=NONE           guifg=NONE    guibg=#25303b
highlight CursorColumn       gui=NONE           guifg=NONE    guibg=#25303b
highlight CursorLine         gui=NONE           guifg=NONE    guibg=#25303b
highlight Visual             gui=NONE           guifg=NONE    guibg=#25303b

highlight Folded             gui=UNDERLINE      guifg=#555555 guibg=NONE
highlight FoldColumn         gui=NONE           guifg=#1c2732 guibg=#1c2732
highlight LineNr             gui=NONE           guifg=#555555 guibg=#181818
highlight CursorLineNr       gui=NONE           guifg=#666666 guibg=#181818

highlight MatchParen         gui=UNDERLINE,BOLD guifg=NONE    guibg=NONE
highlight QuickFixLine       gui=UNDERLINE,BOLD guifg=NONE    guibg=NONE
highlight Search             gui=UNDERLINE,BOLD guifg=NONE    guibg=NONE
highlight IncSearch          gui=UNDERLINE,BOLD guifg=#ffffff guibg=NONE

highlight Cursor             gui=NONE           guifg=#000000 guibg=#ffffff
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
    highlight TabSideBarTitle gui=NONE           guifg=#008888 guibg=#141f2a
    highlight TabSideBarSel   gui=NONE           guifg=#ffffff guibg=#141f2a
    highlight TabSideBar      gui=NONE           guifg=#555555 guibg=#141f2a
    highlight TabSideBarFill  gui=NONE           guifg=#141f2a guibg=#141f2a
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

