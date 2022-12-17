
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

function! s:color(name, n) abort
  let X = 0xee
  let Y = 0x88
  if a:name == 'red'
    return s:rgb(X, Y, Y, a:n)
  elseif a:name == 'green'
    return s:rgb(Y, X, Y, a:n)
  elseif a:name == 'blue'
    return s:rgb(Y, Y, X, a:n)
  elseif a:name == 'purple'
    return s:rgb(X, Y, X, a:n)
  elseif a:name == 'yellow'
    return s:rgb(X, X, Y, a:n)
  elseif a:name == 'gray'
    return s:rgb(0xff, 0xff, 0xff, a:n)
  else
    throw 'invalid name:' .. a:name
  endif
endfunction

let s:base_fg = s:color('gray', 0.9)
let s:base_bg = s:color('gray', 0.07)
let s:vim_border = s:color('gray', 0.11)
let s:popup_border = s:color('green', 1.0)
let s:positive_color = s:color('gray', 0.8)
let s:negative_color = s:color('gray', 0.2)
let s:added_color = s:color('green', 0.7)
let s:removed_color = s:color('red', 0.7)
let s:search_color = s:color('yellow', 1.0)

call s:high('Normal',           s:base_fg,            s:base_bg)

call s:high('Search',           s:search_color,            'NONE',       'UNDERLINE,BOLD')
call s:high('IncSearch',        s:search_color,            'NONE',       'BOLD')

call s:high('Title',            s:color('green', 0.8))
call s:high('Question',         s:color('green', 0.8))
call s:high('Statement',        s:color('blue', 0.9))
call s:high('Keyword',          s:color('purple', 0.8))
call s:high('Type',             s:color('yellow', 0.8))
call s:high('Directory',        s:color('green', 0.8))
call s:high('String',           s:color('red', 0.9))
call s:high('Constant',         s:color('gray', 0.4))
call s:high('PreProc',          s:color('red', 0.9))
call s:high('Identifier',       s:base_fg)
call s:high('Special',          s:base_fg)

call s:high('Folded',           s:negative_color)
call s:high('SpecialKey',       s:negative_color)
call s:high('Comment',          s:negative_color)
call s:high('NonText',          s:negative_color)
call s:high('LineNr',           s:negative_color)

call s:high('Pmenu',            s:negative_color,     s:base_bg)
call s:high('PmenuSbar',        s:negative_color,     s:negative_color)
call s:high('PmenuThumb',       s:positive_color,     s:positive_color)
call s:high('PmenuSel',         s:base_fg,            s:base_bg,    'UNDERLINE,BOLD')

call s:high('PopupBorder',      s:popup_border)

call s:high('diffAdded',        s:added_color)
call s:high('diffRemoved',      s:removed_color)

call s:high('QuickFixLine',     'NONE',               'NONE',       'UNDERLINE,BOLD')

call s:high('VertSplit',        s:vim_border,         s:vim_border)
call s:high('StatusLine',       s:negative_color,     s:vim_border)
call s:high('StatusLineNC',     s:vim_border,         s:vim_border)
call s:high('StatusLineTerm',   s:negative_color,     s:vim_border)
call s:high('StatusLineTermNC', s:vim_border,         s:vim_border)

call s:high('TabSideBar',      s:negative_color,      s:vim_border)
call s:high('TabSideBarFill',  'NONE',                s:vim_border)
call s:high('TabSideBarSel',   s:positive_color,      s:vim_border, 'BOLD')
call s:high('TabSideBarLabel', s:negative_color,      s:vim_border, 'UNDERLINE')

call s:high('CursorIM',        s:base_fg,             s:color('red', 0.8))

let g:terminal_ansi_colors = [
  \ '#000000',
  \ s:removed_color,
  \ s:added_color,
  \ '#e0e000',
  \ '#0000e0',
  \ '#e000e0',
  \ '#00e0e0',
  \ '#e0e0e0',
  \ '#808080',
  \ '#ff4040',
  \ '#40ff40',
  \ s:color('yellow', 0.8),
  \ '#4040ff',
  \ '#ff40ff',
  \ '#40ffff',
  \ '#ffffff',
  \ ]

