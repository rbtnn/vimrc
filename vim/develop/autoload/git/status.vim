
let s:FT = 'gitstatus'

let s:map = {
    \ 'A': { 'regex': '^\(.[MD]\|??\)$', 'cmd': ['add'], },
    \ 'C': { 'regex': '^M.$', 'cmd': ['diff', '--cached', '-w'], },
    \ 'D': { 'regex': '^.M$', 'cmd': ['diff', '-w'], },
    \ 'R': { 'regex': '^.[MD]$', 'cmd': ['restore'], },
    \ 'S': { 'regex': '^[AMD].$', 'cmd': ['restore', '--staged'], },
    \ }

function! git#status#exec() abort
    let opts = {}
    call utils#popupwin#apply_size(opts)
    call utils#popupwin#apply_border(opts)
    let winid = popup_menu([], opts)
    if s:reload_lines(winid)
        call win_execute(winid, 'setfiletype ' .. s:FT)
        call popup_setoptions(winid, {
            \ 'filter': function('s:popup_filter'),
            \ 'callback': function('s:popup_callback'),
            \ })
        call s:fix_cursor_pos(winid)
        call s:update_title(winid)
    else
        call git#internal#echo('Working tree clean!')
        call popup_close(winid)
    endif
endfunction

function! s:reload_lines(winid) abort
    let lines = filter(git#internal#system(['status', '-s']), { _,x -> !empty(x) })
    call popup_settext(a:winid, lines)
    return !empty(lines)
endfunction

function! s:popup_filter(winid, key) abort
    let lnum = line('.', a:winid)
    if s:is_key(a:winid, lnum, a:key, 'A')
        call git#internal#system(['add', s:get_current_path(a:winid, lnum)])
        call s:reload_lines(a:winid)
        call s:fix_cursor_pos(a:winid)
        call s:update_title(a:winid)
        return 1
    elseif s:is_key(a:winid, lnum, a:key, 'C')
        call git#diff#open_diffwindow(['--cached', '-w'], s:get_current_path(a:winid, lnum))
        call s:fix_cursor_pos(a:winid)
        call s:update_title(a:winid)
        return 1
    elseif s:is_key(a:winid, lnum, a:key, 'D')
        call git#diff#open_diffwindow(['-w'], s:get_current_path(a:winid, lnum))
        call s:fix_cursor_pos(a:winid)
        call s:update_title(a:winid)
        return 1
    elseif s:is_key(a:winid, lnum, a:key, 'R')
        call git#internal#system(['restore', s:get_current_path(a:winid, lnum)])
        call s:reload_lines(a:winid)
        call s:fix_cursor_pos(a:winid)
        call s:update_title(a:winid)
        return 1
    elseif s:is_key(a:winid, lnum, a:key, 'S')
        call git#internal#system(['restore', '--staged', s:get_current_path(a:winid, lnum)])
        call s:reload_lines(a:winid)
        call s:fix_cursor_pos(a:winid)
        call s:update_title(a:winid)
        return 1
    elseif char2nr('j') == char2nr(a:key)
        if lnum < line('$', a:winid)
            call utils#popupwin#set_cursorline(a:winid, lnum + 1)
            call s:update_title(a:winid)
        endif
        return 1
    elseif char2nr('k') == char2nr(a:key)
        if 1 < lnum
            call utils#popupwin#set_cursorline(a:winid, lnum - 1)
            call s:update_title(a:winid)
        endif
        return 1
    else
        return utils#popupwin#common_filter(a:winid, a:key)
    endif
endfunction

function! s:is_key(winid, lnum, input_key, expect_key) abort
    if char2nr(a:expect_key) == char2nr(a:input_key)
        let status = get(getbufline(winbufnr(a:winid), a:lnum), 0, '')[:1]
        if has_key(s:map, a:expect_key)
            if status =~# s:map[a:expect_key]['regex']
                return v:true
            endif
        endif
    endif
    return v:false
endfunction

function! s:update_title(winid) abort
    let lnum = line('.', a:winid)
    let status = get(getbufline(winbufnr(a:winid), lnum), 0, '')[:1]
    let title = []
    for key in keys(s:map)
        if status =~# s:map[key]['regex']
            let title += [printf('%s: "%s"', key, join(s:map[key]['cmd']))]
        endif
    endfor
    call popup_setoptions(a:winid, {
        \ 'title': empty(title) ? '' : printf(' %s ', join(title, ', ')),
        \ })
endfunction

function! s:fix_cursor_pos(winid) abort
    let curlnum = line('.', a:winid)
    let toplnum = 1
    let botlnum = line('$', a:winid)
    if curlnum < toplnum
        call utils#popupwin#set_cursorline(a:winid, toplnum)
    elseif botlnum < curlnum
        call utils#popupwin#set_cursorline(a:winid, botlnum)
    endif
endfunction

function! s:get_current_path(winid, lnum) abort
    if -1 != a:lnum
        let rootdir = git#internal#get_rootdir()
        let line = get(getbufline(winbufnr(a:winid), a:lnum), 0, '')[3:]
        if -1 != stridx(line, ' -> ')
            let line = split(line, ' -> ')[1]
        endif
        return expand(rootdir .. '/' .. line)
    endif
    return ''
endfunction

function! s:popup_callback(winid, result) abort
    let path = s:get_current_path(a:winid, a:result)
    if !empty(path)
        execute printf('edit %s', fnameescape(path))
    endif
endfunction

