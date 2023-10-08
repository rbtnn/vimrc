
" ┌──┐
" │  │
" └──┘
const s:borderchars_typeA = [
    \ nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
    \ nr2char(0x250c), nr2char(0x2510), nr2char(0x2518), nr2char(0x2514)]
" ╭──╮
" │  │
" ╰──╯
const s:borderchars_typeB = [
    \ nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
    \ nr2char(0x256d), nr2char(0x256e), nr2char(0x256f), nr2char(0x2570)]

function! gitdiff#popupwin#apply_border(opts, hlname) abort
    if has('gui_running') || (!has('win32') && !has('gui_running'))
        if hlexists(a:hlname)
            call extend(a:opts, {
                \ 'highlight': 'Normal',
                \ 'border': [],
                \ 'padding': [0, 0, 0, 0],
                \ 'borderhighlight': repeat([a:hlname], 4),
                \ 'borderchars': get(g:, 'gitdiff_popupwin_border_type', 1) ? s:borderchars_typeA : s:borderchars_typeB,
                \ }, 'force')
        endif
    endif
    return a:opts
endfunction

function! gitdiff#popupwin#apply_size(opts) abort
    let width = 120
    let height = 20 + 4
    let subwindow_height = 3
    let d = 0
    if has('tabsidebar')
        if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
            let d = &tabsidebarcolumns
        endif
    endif
    if &columns - d < width
        let width = &columns - d
    endif
    if &lines - &cmdheight - subwindow_height < height
        let height = &lines - &cmdheight - subwindow_height
    endif
    let width -= 2
    let height -= 4
    if width < 4
        let width = 4
    endif
    if height < 4
        let height = 4
    endif
    call extend(a:opts, {
        \ 'wrap': 0,
        \ 'scrollbar': 1,
        \ 'minwidth': width, 'maxwidth': width,
        \ 'minheight': height, 'maxheight': height,
        \ 'pos': 'center',
        \ }, 'force')
    return a:opts
endfunction

function! gitdiff#popupwin#set_cursorline(winid, lnum) abort
    call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
    call win_execute(a:winid, 'redraw')
endfunction
