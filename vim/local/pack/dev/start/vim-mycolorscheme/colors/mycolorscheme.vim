
highlight clear
if exists("syntax_on")
	syntax reset
endif

let g:colors_name = 'mycolorscheme'

if !(has('termguicolors') && &termguicolors) && !has('gui_running') && &t_Co != 256
	finish
endif

function! s:high(name, fg, ...) abort
	let bg = get(a:000, 0, 'NONE')
	let gui = get(a:000, 1, 'NONE')
	let cterm = get(a:000, 2, gui)
	execute printf('highlight! %s guifg=%s guibg=%s gui=%s cterm=%s', a:name, a:fg, bg, gui, cterm)
endfunction

let s:base_fg = '#dedede'
let s:base_bg = '#10131a'
let s:vim_border = '#000000'
let s:popup_border = '#00ffff'
let s:positive_color = '#cecece'
let s:negative_color = '#444444'
let s:color_1 = '#be4141'
let s:color_2 = '#bebe41'
let s:color_3 = '#41be41'
let s:color_4 = '#55be55'
let s:color_5 = '#555555'

call s:high('Normal',           s:base_fg,            s:base_bg)

call s:high('Search',           s:color_4,            'NONE',       'UNDERLINE,BOLD')
call s:high('IncSearch',        s:color_4,            'NONE',       'BOLD')

call s:high('Statement',        s:color_2)
call s:high('String',           s:color_1)
call s:high('Constant',         s:color_1)
call s:high('PreProc',          s:base_fg)
call s:high('Keyword',          s:base_fg)
call s:high('Identifier',       s:base_fg)
call s:high('Special',          s:base_fg)
call s:high('Type',             s:base_fg)

call s:high('Folded',           s:color_5)
call s:high('SpecialKey',       s:color_5)
call s:high('Comment',          s:color_5)
call s:high('NonText',          s:color_5)

call s:high('Pmenu',            s:negative_color,     s:base_bg)
call s:high('PmenuSel',         s:base_fg,            s:base_bg,    'UNDERLINE,BOLD')
call s:high('PopupBorder',      s:popup_border)

call s:high('diffAdded',        s:color_3)
call s:high('diffRemoved',      s:color_1)

call s:high('QuickFixLine',     'NONE',               'NONE',       'UNDERLINE,BOLD')

call s:high('VertSplit',        s:vim_border,         s:vim_border)
call s:high('StatusLine',       s:positive_color,     s:vim_border, 'BOLD')
call s:high('StatusLineNC',     s:negative_color,     s:vim_border)
call s:high('StatusLineTerm',   s:positive_color,     s:vim_border, 'BOLD')
call s:high('StatusLineTermNC', s:negative_color,     s:vim_border)

call s:high('TabSideBar',      s:negative_color,      s:vim_border)
call s:high('TabSideBarFill',  'NONE',                s:vim_border)
call s:high('TabSideBarSel',   s:positive_color,      s:vim_border, 'BOLD')
call s:high('TabSideBarLabel', s:negative_color,      s:vim_border, 'UNDERLINE')

call s:high('CursorIM',        s:color_1,             s:base_bg)

