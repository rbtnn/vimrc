
function! tabpanel#highlight(s, h) abort
  return (empty(a:h) ? '' : '%#' .. a:h .. '#') .. a:s .. '%#TabPanel#'
endfunction

function! tabpanel#width() abort
  let s:width = -1
  if s:width == -1
    let s:width = 20
    let n = str2nr(matchstr(&tabpanelopt, 'columns:\zs\d\+'))
    if 0 < n
      let s:width = n
    endif
    if &tabpanelopt =~# 'vert'
      let s:width -= 1
    endif
  endif
  return s:width
endfunction

function! tabpanel#symbol(bname) abort
  let symbol = '  '
  let symbol_hi = ''
  if !empty(a:bname)
    if exists('*WebDevIconsGetFileTypeSymbol')
      let symbol = WebDevIconsGetFileTypeSymbol(a:bname)
    endif
    if exists('g:glyph_palette#palette')
      for key in keys(g:glyph_palette#palette)
        if -1 != index(g:glyph_palette#palette[key], trim(symbol))
          let symbol_hi = key
        endif
      endfor
    endif
  endif
  return tabpanel#highlight(symbol, symbol_hi)
endfunction

function! tabpanel#make_line(tabnr, winnr, bufnr) abort
  let modified = getbufvar(a:bufnr, "&modified")
  let readonly = getbufvar(a:bufnr, "&readonly")
  let buftype = getbufvar(a:bufnr, "&buftype")
  let bname = fnamemodify(bufname(a:bufnr), ":t")
  if empty(bname)
    let bname = '[No Name]'
  endif
  let text =
    \    tabpanel#symbol(bname)
    \ .. bname
    \ .. (modified ? tabpanel#highlight('[+]', 'Identifier') : '')
    \ .. (readonly ? tabpanel#highlight('[R]', 'Type') : '')
  if !empty(buftype)
    let text = '   ' .. tabpanel#highlight('[' .. buftype .. ']', 'LineNr')
  endif
  return
    \    '  '
    \ .. ((tabpagenr() == a:tabnr) && (winnr() == a:winnr) ? tabpanel#highlight('*', 'Directory') : ' ')
    \ .. text
endfunction

function! tabpanel#exec() abort
  try
    let lines = map([
      \   '',
      \   ' ----------',
      \   printf(" TabPage %d", g:actual_curtabpage),
      \   ' ----------'
      \ ], { _, s -> tabpanel#highlight(s, 'Question') })
    for x in filter(getwininfo(), { i,x -> x.tabnr == g:actual_curtabpage })
      let lines += [tabpanel#make_line(x.tabnr, x.winnr, x.bufnr)]
    endfor
    return join(lines, "\n")
  catch
    let exception_lines = split(v:exception, repeat('.', tabpanel#width()) .. '\zs')
    let throwpoint_lines = split(v:throwpoint, repeat('.', tabpanel#width()) .. '\zs')
    call map(exception_lines, { _, s -> tabpanel#highlight(s, 'ErrorMsg') })
    call map(throwpoint_lines, { _, s -> tabpanel#highlight(s, 'ErrorMsg') })
    return join(exception_lines + throwpoint_lines, "\n")
  endtry
endfunction
