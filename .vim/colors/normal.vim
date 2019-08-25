
if !((has('win32') && has('gui_running')) || (has('termguicolors') && getbufvar(bufnr('%'), '&termguicolors', 0)))
    finish
endif

highlight clear

if exists('syntax_on')
    syntax reset
endif

let g:colors_name = substitute(fnamemodify(expand('<sfile>'), ':t'), '.vim', '', '')

highlight Normal             gui=NONE           guifg=#000000 guibg=#ffffff 
highlight EndOfBuffer        gui=NONE           guifg=#eeeeee guibg=#ffffff

highlight WildMenu           gui=NONE           guifg=#000000 guibg=#aaaa00 
highlight TabLineSel         gui=NONE           guifg=#000000 guibg=#aaaa00 
highlight TabLine            gui=NONE           guifg=#666666 guibg=#323639 
highlight TabLineFill        gui=NONE           guifg=#666666 guibg=#323639 
highlight LineNr             gui=NONE           guifg=#666666 guibg=#323639
highlight CursorLineNr       gui=NONE           guifg=#aaaaaa guibg=#323639
highlight StatusLine         gui=NONE           guifg=#aaaaaa guibg=#323639 
highlight StatusLineTerm     gui=NONE           guifg=#aaaaaa guibg=#323639 
highlight StatusLineNC       gui=NONE           guifg=#666666 guibg=#323639 
highlight StatusLineTermNC   gui=NONE           guifg=#666666 guibg=#323639 
highlight VertSplit          gui=NONE           guifg=NONE    guibg=#323639 

highlight ColorColumn        gui=NONE           guifg=NONE    guibg=#f7f7f7 
highlight CursorLine         gui=NONE           guifg=NONE    guibg=#f7f7f7 
highlight CursorColumn       gui=NONE           guifg=NONE    guibg=#f7f7f7 

highlight Pmenu              gui=NONE           guifg=#aaaaaa guibg=#eeeeee
highlight PmenuSel           gui=underline      guifg=NONE    guibg=#eeeeee
highlight PmenuSbar          gui=NONE           guifg=NONE    guibg=#f1f1f1
highlight PmenuThumb         gui=NONE           guifg=NONE    guibg=#c1c1c1

highlight Search             gui=NONE           guifg=#666666 guibg=#cccc22
highlight IncSearch          gui=NONE           guifg=#666666 guibg=#cccc22
highlight Cursor             gui=NONE           guifg=#ffffff guibg=#323639
highlight Visual             gui=NONE           guifg=#ffffff guibg=#323639

highlight Comment            gui=NONE           guifg=#dddddd guibg=NONE

highlight Folded             gui=underline      guifg=#333333 guibg=NONE
highlight Title              gui=NONE           guifg=#333333 guibg=NONE
highlight Keyword            gui=NONE           guifg=#333333 guibg=NONE
highlight Type               gui=NONE           guifg=#333333 guibg=NONE
highlight Identifier         gui=NONE           guifg=#33cc33 guibg=NONE
highlight Special            gui=NONE           guifg=#3333cc guibg=NONE
highlight Statement          gui=NONE           guifg=#cc33cc guibg=NONE
highlight Preproc            gui=NONE           guifg=#cc3333 guibg=NONE
highlight String             gui=NONE           guifg=#33cc33 guibg=NONE
highlight Constant           gui=NONE           guifg=#3333cc guibg=NONE

if has('tabsidebar')
    highlight TabSideBarSel  gui=NONE           guifg=#484848 guibg=#dcdcdc 
    highlight TabSideBar     gui=NONE           guifg=#484848 guibg=#f5f5f5 
    highlight TabSideBarFill gui=NONE           guifg=#484848 guibg=#f5f5f5 
endif

if 0
    set laststatus=2 statusline=%!StatusLine()
    function! StatusLine() abort
        let l = line('.')
        let c = col('.')
        let syn_id = synID(l, c, 1)
        let trans_id = syn_id->synIDtrans()
        let name = syn_id->synIDattr('name')
        let name_t = trans_id->synIDattr('name')
        let fg = syn_id->synIDattr('fg#')
        let bg = syn_id->synIDattr('bg#')
        let fg = empty(fg) ? 'NONE' : fg
        let bg = empty(bg) ? 'NONE' : bg
        let display_name = empty(name_t) ? 'Normal' : (name == name_t ? name : printf('%s -> %s', name, name_t))
        return printf('%s fg=%s bg=%s', display_name, fg, bg)
    endfunction
endif

