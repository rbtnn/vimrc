
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
" Basic Highlights (Inspired by ayu-theme/ayu-vim)
highlight!      Constant           gui=NONE           cterm=NONE           guifg=#ffee99 guibg=NONE    ctermbg=NONE
highlight!      PreProc            gui=NONE           cterm=NONE           guifg=#e6b673 guibg=NONE    ctermbg=NONE
highlight!      Title              gui=NONE           cterm=NONE           guifg=#ff7733 guibg=NONE    ctermbg=NONE
highlight!      Type               gui=NONE           cterm=NONE           guifg=#36a3d9 guibg=NONE    ctermbg=NONE
highlight!      UnderLined         gui=NONE           cterm=NONE           guifg=#36a3d9 guibg=NONE    ctermbg=NONE
highlight!      Identifier         gui=NONE           cterm=NONE           guifg=#36a3d9 guibg=NONE    ctermbg=NONE
highlight!      Directory          gui=NONE           cterm=NONE           guifg=#3e4b59 guibg=NONE    ctermbg=NONE
highlight!      Statement          gui=NONE           cterm=NONE           guifg=#ff7733 guibg=NONE    ctermbg=NONE
highlight!      Special            gui=NONE           cterm=NONE           guifg=#e6b673 guibg=NONE    ctermbg=NONE
highlight!      SpecialKey         gui=NONE           cterm=NONE           guifg=#253340 guibg=NONE    ctermbg=NONE
highlight!      NonText            gui=NONE           cterm=NONE           guifg=#205020 guibg=NONE    ctermbg=NONE
highlight!      Comment            gui=NONE           cterm=NONE           guifg=#5c6773 guibg=NONE    ctermbg=NONE
" --------------------------------------------------------------------------------------------------------------------



highlight!      Error              gui=NONE           cterm=NONE           guifg=#ffffff guibg=#ff0000 ctermbg=NONE

highlight!      Cursor             gui=NONE           cterm=NONE           guifg=#000000 guibg=#e0e0e0
highlight!      CursorIM           gui=NONE           cterm=NONE           guifg=#ffffff guibg=#ff0000

highlight!      Pmenu              gui=NONE           cterm=NONE           guifg=#e6e1cf guibg=#253340
highlight!      PmenuSbar          gui=NONE           cterm=NONE           guifg=#000000 guibg=#253340
highlight!      PmenuSel           gui=BOLD           cterm=BOLD           guifg=#e6e1cf guibg=#253340
highlight!      PmenuThumb         gui=NONE           cterm=NONE           guifg=NONE    guibg=#cccccc ctermfg=NONE

highlight!      PopupSelected      gui=BOLD           cterm=BOLD           guifg=#04aadd guibg=#12121a

highlight!      StatusLine         gui=NONE           cterm=NONE           guifg=#e6e1cf guibg=#14191f
highlight!      StatusLineNC       gui=NONE           cterm=NONE           guifg=#3e4b59 guibg=#14191f
highlight!      StatusLineTerm     gui=NONE           cterm=NONE           guifg=#e6e1cf guibg=#14191f
highlight!      StatusLineTermNC   gui=NONE           cterm=NONE           guifg=#3e4b59 guibg=#14191f
highlight!      VertSplit          gui=NONE           cterm=NONE           guifg=#14191f guibg=#14191f

highlight!      TabLine            gui=NONE           cterm=NONE           guifg=#888888 guibg=#212121
highlight!      TabLineFill        gui=NONE           cterm=NONE           guifg=NONE    guibg=#212121 ctermfg=NONE
highlight!      TabLineSel         gui=BOLD           cterm=BOLD           guifg=#04aadd guibg=#212121

highlight!      DiffAdd            gui=NONE           cterm=NONE           guifg=#118811 guibg=NONE    ctermbg=NONE
highlight!      DiffChange         gui=BOLD           cterm=BOLD           guifg=#993399 guibg=NONE    ctermbg=NONE
highlight!      DiffDelete         gui=NONE           cterm=NONE           guifg=#dd2c2c guibg=NONE    ctermbg=NONE
highlight!      DiffText           gui=BOLD,UNDERLINE cterm=BOLD,UNDERLINE guifg=#993399 guibg=NONE    ctermbg=NONE

highlight!      CursorLine         gui=UNDERLINE      cterm=UNDERLINE      guifg=NONE    guibg=NONE    ctermfg=NONE ctermbg=NONE
highlight!      CursorLineNr       gui=BOLD           cterm=BOLD           guifg=#04aadd guibg=#373737
highlight!      Terminal           gui=NONE           cterm=NONE           guifg=#e0e0e0 guibg=#0f1419
highlight!      Normal             gui=NONE           cterm=NONE           guifg=#e6e1cf guibg=#0f1419
highlight!      EndOfBuffer        gui=NONE           cterm=NONE           guifg=#1f1f1f guibg=#0f1419
highlight!      Visual             gui=NONE           cterm=NONE           guifg=NONE    guibg=#253340
highlight!      LineNr             gui=NONE           cterm=NONE           guifg=#2d3640 guibg=NONE
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

highlight!      TabSideBar          gui=NONE          cterm=NONE           guifg=#e6e1cf guibg=#14191f
highlight!      TabSideBarFill      gui=NONE          cterm=NONE           guifg=NONE    guibg=#14191f ctermfg=NONE
highlight!      TabSideBarSel       gui=BOLD          cterm=BOLD           guifg=#e6e1cf guibg=#14191f
highlight!      TabSideBarTitle     gui=BOLD          cterm=NONE           guifg=#ff7733 guibg=#14191f

