
const s:borderchars_list = {
    \   '_': ['-', '|', '-', '|', '+', '+', '+', '+'],
    \   'A': [nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
    \         nr2char(0x250c), nr2char(0x2510), nr2char(0x2518), nr2char(0x2514)],
    \   'B': [nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
    \         nr2char(0x256d), nr2char(0x256e), nr2char(0x256f), nr2char(0x2570)],
    \ }
const s:borderchars_selected = 'B'

const s:hlname1 = 'VimrcDevPopupBorder'
const s:hlname2 = 'NonText'

function! utils#popupwin#notification(msg) abort
    if has('gui_running') || (!has('win32') && !has('gui_running'))
        if hlexists(s:hlname1)
            call popup_notification(a:msg, {
                \ 'highlight': s:hlname2,
                \ 'pos': 'center',
                \ 'border': [],
                \ 'padding': [1, 1, 1, 1],
                \ 'borderhighlight': repeat([s:hlname1], 4),
                \ 'borderchars': s:borderchars_list[s:borderchars_selected],
                \ })
        else
            echo a:msg
        endif
    else
        echo a:msg
    endif
endfunction

function! utils#popupwin#apply_border(opts) abort
    if has('gui_running') || (!has('win32') && !has('gui_running'))
        if hlexists(s:hlname1)
            call extend(a:opts, {
                \ 'highlight': s:hlname2,
                \ 'border': [],
                \ 'padding': [0, 1, 0, 1],
                \ 'borderhighlight': repeat([s:hlname1], 4),
                \ 'borderchars': s:borderchars_list[s:borderchars_selected],
                \ }, 'force')
        endif
    endif
    return a:opts
endfunction

function! utils#popupwin#apply_size(opts) abort
    let maxwidth = &columns - 5
    if has('tabsidebar')
        if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
            let maxwidth -= &tabsidebarcolumns
        endif
    endif
    let minwidth = 120
    if maxwidth < minwidth
        let minwidth = maxwidth
    endif
    let height = &lines / 3
    let subwindow_height = 3
    if &lines - subwindow_height < height
        let height = &lines - subwindow_height
    endif
    call extend(a:opts, {
        \ 'wrap': 0,
        \ 'scrollbar': 1,
        \ 'minwidth': minwidth, 'maxwidth': maxwidth,
        \ 'minheight': height, 'maxheight': height,
        \ 'pos': 'center',
        \ }, 'force')
    return a:opts
endfunction

function! utils#popupwin#set_cursorline(winid, lnum) abort
    call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
    "call win_execute(a:winid, 'redraw')
endfunction

function! utils#popupwin#common_filter(winid, key) abort
    let lnum = line('.', a:winid)
    if (10 == char2nr(a:key)) || (14 == char2nr(a:key))
        " Ctrl-n or Ctrl-j
        if lnum == line('$', a:winid)
            call utils#popupwin#set_cursorline(a:winid, 1)
        else
            call utils#popupwin#set_cursorline(a:winid, lnum + 1)
        endif
        return 1
    elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key))
        " Ctrl-p or Ctrl-k
        if lnum == 1
            call utils#popupwin#set_cursorline(a:winid, line('$', a:winid))
        else
            call utils#popupwin#set_cursorline(a:winid, lnum - 1)
        endif
        return 1
    elseif 0x20 == char2nr(a:key)
        return popup_filter_menu(a:winid, "\<cr>")
    elseif 0x0d == char2nr(a:key)
        return popup_filter_menu(a:winid, "\<cr>")
    else
        if char2nr(a:key) < 0x20
            return popup_filter_menu(a:winid, "\<esc>")
        else
            return popup_filter_menu(a:winid, a:key)
        endif
    endif
endfunction
