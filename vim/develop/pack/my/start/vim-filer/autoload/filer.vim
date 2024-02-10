
function! filer#exec(basedir) abort
    let g:filer_maximum = get(g:, 'filer_maximum', 1000)
    if popupwin#check_able_to_open('filer')
        let basedir = s:fix_path(a:basedir)
        let winid = popup_menu([], s:get_popupwin_options_main(basedir))
        if -1 != winid
            call popup_setoptions(winid, {
                \ 'filter': function('s:popup_filter', [basedir]),
                \ 'callback': function('s:popup_callback', [basedir]),
                \ })
            call popupwin#set_options(v:false)
            call s:search_files(basedir, winid)
            call s:set_cursor_at_curr_file(basedir, winid)
        endif
    endif
endfunction

function! s:fix_path(path) abort
    return fnamemodify(resolve(a:path), ':p:gs?\\?/?')
endfunction

function! s:get_popupwin_options_main(basedir) abort
    return {
        \ 'title': printf(' [filer] %s ', a:basedir)
        \ }
endfunction

function! s:goup_dir(path) abort
    let xs = split(a:path, '/', 1)
    for i in range(len(xs) - 1, 0, -1)
        if !empty(xs[i])
            call remove(xs, i)
            break
        endif
    endfor
    return join(xs, '/')
endfunction

function! s:popup_filter(basedir, winid, key) abort
    let lnum = line('.', a:winid)
    if char2nr('h') == char2nr(a:key)
        if s:is_topdir(a:basedir)
            return 1
        else
            call filer#exec(s:goup_dir(a:basedir))
            return popupwin#common_filter(a:winid, "\<esc>")
        endif
    elseif char2nr('l') == char2nr(a:key)
        return popupwin#common_filter(a:winid, "\<cr>")
    elseif char2nr('~') == char2nr(a:key)
        call filer#exec(expand('~'))
        return popupwin#common_filter(a:winid, "\<esc>")
    elseif 0x0d == char2nr(a:key)
        let line = trim(get(getbufline(winbufnr(a:winid), lnum), 0, ''))
        let path = s:fix_path(a:basedir .. line)
        if s:maybe_binaryfile(path)
            echohl Error
            echo 'maybe a binary file!'
            echohl None
            return 0
        else
            return popupwin#common_filter(a:winid, "\<cr>")
        endif
    else
        return popupwin#common_filter(a:winid, a:key)
    endif
endfunction

function! s:popup_callback(basedir, winid, result) abort
    if -1 != a:result
        let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
        let path = s:fix_path(a:basedir .. line)
        if isdirectory(path)
            call filer#exec(path)
        else
            call fileopener#open_file(path)
        endif
    endif
endfunction


function! s:is_topdir(path) abort
    return   (a:path =~# '^/$')
        \ || (a:path =~# '^[\/][\/]$')
        \ || (a:path =~# '^[A-Z]:[\/]$')
endfunction

function! s:maybe_binaryfile(path) abort
    return 0 < len(filter(readblob(a:path, 0, 100), { i,x -> x == 0x00 }))
endfunction

function! s:set_cursor_at_curr_file(basedir, winid) abort
    let curr_dir = expand('%:p:h')
    let curr_fname = expand('%:p:t')
    if s:fix_path(curr_dir) == a:basedir
        let i = index(getbufline(winbufnr(a:winid), 1, '$'), curr_fname)
        if -1 != i
            call popupwin#set_cursorline(a:winid, i + 1)
        endif
    endif
endfunction

function! s:search_files(basedir, winid) abort
    try
        call popup_settext(a:winid, '')
        let n = g:filer_maximum - 1
        if n < 1
            let n = 1
        endif
        let xs = map(readdir(a:basedir)[:n], { _, x -> isdirectory(a:basedir .. '/' .. x) ? x .. '/' : x })
        call filter(xs, { _, x
            \ -> (x !~# '\c^NTUSER.')
            \ && (x !~# '^\$')
            \ && (x !~# '^desktop.ini$')
            \ && (x !~# '^\.DS_Store$') })
        call popup_settext(a:winid, xs)
        call popup_setoptions(a:winid, s:get_popupwin_options_main(a:basedir))
        call win_execute(a:winid, 'call clearmatches()')
        call win_execute(a:winid, 'silent call matchadd(''Question'', ''^.*/$'')')
    catch /^Vim\%((\a\+)\)\=:E484:/
        echohl Error
        echo v:exception
        echohl None
    endtry
    redraw
endfunction