
highlight clear
if exists("syntax_on")
	syntax reset
endif

let g:colors_name = 'fire'

if !(has('termguicolors') && &termguicolors) && !has('gui_running') && &t_Co != 256
	finish
endif

function! s:high(name, fg, ...) abort
	let bg = get(a:000, 0, 'NONE')
	let gui = get(a:000, 1, 'NONE')
	let cterm = get(a:000, 2, gui)
	execute printf('highlight! %s guifg=%s guibg=%s gui=%s cterm=%s', a:name, a:fg, bg, gui, cterm)
endfunction

function! s:rgb(r, g, b, ...) abort
	let r = float2nr(a:r * get(a:000, 0, 1.0))
	let g = float2nr(a:g * get(a:000, 0, 1.0))
	let b = float2nr(a:b * get(a:000, 0, 1.0))
	return printf('#%02x%02x%02x', r > 255 ? 255 : r, g > 255 ? 255 : g, b > 255 ? 255 : b)
endfunction

function! s:accent_color(n) abort
	return s:rgb(0xdc, 0x50, 0x50, a:n)
endfunction

let s:base_fg = s:rgb(204, 204, 204)
let s:base_bg = s:rgb(8, 8, 8)
let s:vim_border = s:rgb(15, 15, 15)
let s:popup_border = s:accent_color(1.0)
let s:positive_color = s:rgb(224, 224, 224)
let s:negative_color = s:rgb(44, 44, 44)
let s:added_color = s:rgb(0x55, 0xbe, 0x55, 0.8)
let s:removed_color = s:accent_color(0.9)
let s:search_color = s:accent_color(1.1)
let s:color_1 = s:accent_color(0.9)
let s:color_2 = s:accent_color(0.6)

call s:high('Normal',           s:base_fg,            s:base_bg)

call s:high('Search',           s:search_color,            'NONE',       'UNDERLINE,BOLD')
call s:high('IncSearch',        s:search_color,            'NONE',       'BOLD')

call s:high('Statement',        s:color_1)
call s:high('Keyword',          s:color_1)
call s:high('Type',             s:color_1)
call s:high('String',           s:color_2)
call s:high('Constant',         s:color_2)
call s:high('PreProc',          s:color_2)
call s:high('Identifier',       s:base_fg)
call s:high('Special',          s:base_fg)

call s:high('Folded',           s:negative_color)
call s:high('SpecialKey',       s:negative_color)
call s:high('Comment',          s:negative_color)
call s:high('NonText',          s:negative_color)

call s:high('Pmenu',            s:negative_color,     s:base_bg)
call s:high('PmenuSel',         s:base_fg,            s:base_bg,    'UNDERLINE,BOLD')
call s:high('PopupBorder',      s:popup_border)

call s:high('diffAdded',        s:added_color)
call s:high('diffRemoved',      s:removed_color)

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

