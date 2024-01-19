
function! filer#exec(basedir) abort
    call vimrc#init()
    if utils#popupwin#check_able_to_open('filer')
        let basedir = s:fix_path(a:basedir)
        let winid = popup_menu([], s:get_popupwin_options_main(basedir))
        if -1 != winid
            call popup_setoptions(winid, {
                \ 'filter': function('s:popup_filter', [basedir]),
                \ 'callback': function('s:popup_callback', [basedir]),
                \ })
            call utils#popupwin#set_options(v:false)
            call s:search_files(basedir, winid)
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
            return utils#popupwin#common_filter(a:winid, "\<esc>")
        endif
    elseif char2nr('l') == char2nr(a:key)
        return utils#popupwin#common_filter(a:winid, "\<cr>")
    elseif char2nr('~') == char2nr(a:key)
        call filer#exec(expand('~'))
        return utils#popupwin#common_filter(a:winid, "\<esc>")
    else
        return utils#popupwin#common_filter(a:winid, a:key)
    endif
endfunction

function! s:popup_callback(basedir, winid, result) abort
    if -1 != a:result
        let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
        let path = s:fix_path(a:basedir .. line)
        if isdirectory(path)
            call filer#exec(path)
        else
            call vimrc#open_file(path)
        endif
    endif
endfunction


function! s:is_topdir(path) abort
    return   (a:path =~# '^/$')
        \ || (a:path =~# '^[\/][\/]$')
        \ || (a:path =~# '^[A-Z]:[\/]$')
endfunction

function! s:search_files(basedir, winid) abort
    try
        call popup_settext(a:winid, '')
        let n = g:filer_maximum - 1
        if n < 1
            let n = 1
        endif
        let xs = map(readdir(a:basedir)[:n], { _, x -> isdirectory(a:basedir .. '/' .. x) ? x .. '/' : x })
        call popup_settext(a:winid, xs)
        call popup_setoptions(a:winid, s:get_popupwin_options_main(a:basedir))
        call win_execute(a:winid, 'call clearmatches()')
        call win_execute(a:winid, 'silent call matchadd(''Question'', ''^.*/$'')')
    catch /^Vim\%((\a\+)\)\=:E484:/
        call vimrc#error(v:exception)
    endtry
    redraw
endfunction
