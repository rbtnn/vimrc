"const s:borderchars_list = {
"    \   '_': ['-', '|', '-', '|', '*', '*', '*', '*'],
"    \   'A': [nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
"    \         nr2char(0x250c), nr2char(0x2510), nr2char(0x2518), nr2char(0x2514)],
"    \   'B': [nr2char(0x2500), nr2char(0x2502), nr2char(0x2500), nr2char(0x2502),
"    \         nr2char(0x256d), nr2char(0x256e), nr2char(0x256f), nr2char(0x2570)],
"    \ }
const s:hlname = 'VimrcDevPopupWin'

let s:current_position_index = get(s:, 'current_position_index', 0)

function! utils#popupwin#set_options(toggle_pos) abort
    let i = a:toggle_pos ? (s:current_position_index + 1) % 5 : s:current_position_index
    let winid = get(popup_list(), 0, -1)
    if -1 != winid
        let padding_width = 2
        let maxwidth = &columns - 5 - s:get_tabsidebarcolumns()
        let minwidth = (maxwidth < 120) ? 80 : 120
        if maxwidth < minwidth
            let minwidth = maxwidth
        endif
        let height = &lines * 2 / 3
        if &lines < height
            let height = &lines
        endif
        call popup_setoptions(winid, {
            \ 'wrap': 0,
            \ 'scrollbar': 0,
            \ 'minwidth': minwidth, 'maxwidth': maxwidth,
            \ 'minheight': height, 'maxheight': height,
            \ })
        if has('gui_running') || (!has('win32') && !has('gui_running'))
            call popup_setoptions(winid, {
                \ 'highlight': s:hlname,
                \ 'border': [0, 0, 0, 0],
                \ 'padding': [0, 1, 0, 1],
                \ })
        endif
        let d = getwininfo(winid)[0]['width'] + s:get_tabsidebarcolumns() + padding_width - 1
        let opts = popup_getoptions(winid)
        if 0 == i
            call extend(opts, {
                \ 'pos': 'center',
                \ }, 'force')
        elseif 1 == i
            call extend(opts, {
                \ 'line': 1,
                \ 'col': 1,
                \ 'pos': 'topleft',
                \ }, 'force')
        elseif 2 == i
            call extend(opts, {
                \ 'line': 1,
                \ 'col': &columns - d,
                \ 'pos': 'topleft',
                \ }, 'force')
        elseif 3 == i
            call extend(opts, {
                \ 'line': &lines - &cmdheight,
                \ 'col': &columns - d,
                \ 'pos': 'botleft',
                \ }, 'force')
        elseif 4 == i
            call extend(opts, {
                \ 'line': &lines - &cmdheight,
                \ 'col': 1,
                \ 'pos': 'botleft',
                \ }, 'force')
        endif
        call popup_setoptions(winid, opts)
        let s:current_position_index = i
    endif
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
    elseif 0x11 == char2nr(a:key)
        " Ctrl-q
        call utils#popupwin#set_options(v:true)
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

function! s:get_tabsidebarcolumns() abort
    let d = 0
    if has('tabsidebar')
        if (2 == &showtabsidebar) || ((1 == &showtabsidebar) && (1 < tabpagenr('$')))
            let d = &tabsidebarcolumns
        endif
    endif
    return d
endfunction
