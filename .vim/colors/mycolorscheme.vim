
if !has('gui_running')
	if $TERM_PROGRAM == 'Apple_Terminal'
		finish
	elseif exists('&termguicolors')
		set termguicolors
	else
		finish
	endif
endif

highlight clear

if exists('syntax_on')
	syntax reset
endif

let g:colors_name = substitute(fnamemodify(expand('<sfile>'), ':t'), '.vim', '', '')

" --------------------------------------------------------------------------------------------------------------------
" Basic Highlights

" Red
highlight!      Constant           gui=NONE           cterm=NONE           guifg=#ff6666 guibg=NONE    ctermbg=NONE
highlight!      PreProc            gui=NONE           cterm=NONE           guifg=#ff6666 guibg=NONE    ctermbg=NONE

" Blue
highlight!      Title              gui=NONE           cterm=NONE           guifg=#0477fb guibg=NONE    ctermbg=NONE
highlight!      Type               gui=NONE           cterm=NONE           guifg=#0477fb guibg=NONE    ctermbg=NONE
highlight!      UnderLined         gui=NONE           cterm=NONE           guifg=#0477fb guibg=NONE    ctermbg=NONE
highlight!      Identifier         gui=NONE           cterm=NONE           guifg=#0477fb guibg=NONE    ctermbg=NONE

" Green
highlight!      Directory          gui=NONE           cterm=NONE           guifg=#04bb88 guibg=NONE    ctermbg=NONE
highlight!      Statement          gui=NONE           cterm=NONE           guifg=#04bb88 guibg=NONE    ctermbg=NONE

" Yellow
highlight!      Special            gui=NONE           cterm=NONE           guifg=#b4b755 guibg=NONE    ctermbg=NONE

" Dark Green
highlight!      SpecialKey         gui=NONE           cterm=NONE           guifg=#205020 guibg=NONE    ctermbg=NONE
highlight!      NonText            gui=NONE           cterm=NONE           guifg=#205020 guibg=NONE    ctermbg=NONE
highlight!      Comment            gui=NONE           cterm=NONE           guifg=#205020 guibg=NONE    ctermbg=NONE

" --------------------------------------------------------------------------------------------------------------------



highlight!      Error              gui=NONE           cterm=NONE           guifg=#ffffff guibg=#ff0000 ctermbg=NONE

highlight!      Cursor             gui=NONE           cterm=NONE           guifg=#ffffff guibg=#ff00ff
highlight!      CursorIM           gui=NONE           cterm=NONE           guifg=#000000 guibg=#cc0000

highlight!      Pmenu              gui=NONE           cterm=NONE           guifg=#888888 guibg=#040410
highlight!      PmenuSbar          gui=NONE           cterm=NONE           guifg=#000000 guibg=#040410
highlight!      PmenuSel           gui=BOLD           cterm=BOLD           guifg=#04aadd guibg=#040410
highlight!      PmenuThumb         gui=NONE           cterm=NONE           guifg=NONE    guibg=#cccccc ctermfg=NONE

highlight!      PopupSelected      gui=BOLD           cterm=BOLD           guifg=#04aadd guibg=#12121a

highlight!      StatusLine         gui=NONE           cterm=NONE           guifg=#cccccc guibg=#016699
highlight!      StatusLineNC       gui=NONE           cterm=NONE           guifg=#cccccc guibg=#01669a
highlight!      StatusLineTerm     gui=NONE           cterm=NONE           guifg=#cccccc guibg=#016699
highlight!      StatusLineTermNC   gui=NONE           cterm=NONE           guifg=#cccccc guibg=#01669a
highlight!      VertSplit          gui=NONE           cterm=NONE           guifg=#016699 guibg=#016699

highlight!      TabLine            gui=NONE           cterm=NONE           guifg=#888888 guibg=#212121
highlight!      TabLineFill        gui=NONE           cterm=NONE           guifg=NONE    guibg=#212121 ctermfg=NONE
highlight!      TabLineSel         gui=BOLD           cterm=BOLD           guifg=#04aadd guibg=#212121

highlight!      DiffAdd            gui=NONE           cterm=NONE           guifg=#118811 guibg=NONE    ctermbg=NONE
highlight!      DiffChange         gui=BOLD           cterm=BOLD           guifg=#993399 guibg=NONE    ctermbg=NONE
highlight!      DiffDelete         gui=NONE           cterm=NONE           guifg=#dd2c2c guibg=NONE    ctermbg=NONE
highlight!      DiffText           gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE guifg=#993399 guibg=NONE    ctermbg=NONE

highlight!      CursorLine         gui=UNDERLINE      cterm=UNDERLINE      guifg=NONE    guibg=NONE    ctermfg=NONE ctermbg=NONE
highlight!      CursorLineNr       gui=BOLD           cterm=BOLD           guifg=#04aadd guibg=#373737
highlight!      Terminal           gui=NONE           cterm=NONE           guifg=#e0e0e0 guibg=#00000a
highlight!      Normal             gui=NONE           cterm=NONE           guifg=#ffffff guibg=#00000a
highlight!      EndOfBuffer        gui=NONE           cterm=NONE           guifg=#1f1f1f guibg=#00000a
highlight!      Visual             gui=NONE           cterm=NONE           guifg=#aaaaaa guibg=#191919
highlight!      LineNr             gui=NONE           cterm=NONE           guifg=#888888 guibg=#0a0a0a
highlight!      QuickFixLine       gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE guifg=NONE    guibg=NONE    ctermfg=NONE ctermbg=NONE
highlight!      Search             gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE guifg=NONE    guibg=NONE    ctermfg=NONE ctermbg=NONE
highlight!      SignColumn         gui=NONE           cterm=NONE           guifg=NONE    guibg=NONE    ctermfg=NONE ctermbg=NONE
highlight!      WildMenu           gui=NONE           cterm=NONE           guifg=#000000 guibg=#55ddf5

highlight! link ErrorMsg           Error
highlight! link WarningMsg         MoreMsg
highlight! link Folded             Visual
highlight! link IncSearch          Search
highlight! link diffAdded          DiffAdd
highlight! link diffRemoved        DiffDelete

if !has('tabsidebar')
	finish
endif

highlight!      TabSideBar          gui=NONE          cterm=NONE           guifg=#888888 guibg=#080813
highlight!      TabSideBarFill      gui=NONE          cterm=NONE           guifg=NONE    guibg=#080813 ctermfg=NONE
highlight!      TabSideBarSel       gui=BOLD          cterm=BOLD           guifg=#dddddd guibg=#080813
highlight!      TabSideBarTitle     gui=BOLD          cterm=NONE           guifg=#3333aa guibg=#080813

