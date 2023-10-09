
let s:subwinid = get(s:, 'subwinid', -1)

function! lsfiles#exec(q_bang) abort
    let g:lsfiles_height = get(g:, 'lsfiles_height', 10)
    let g:lsfiles_ignore_exts = get(g:, 'lsfiles_ignore_exts', [
        \ 'exe', 'o', 'obj', 'xls', 'doc', 'xlsx', 'docx', 'dll', 'png', 'jpg', 'ico', 'pdf', 'mp3', 'zip',
        \ 'ttf', 'gif', 'otf', 'wav', 'm4a', 'ai', 'tgz'
        \ ])
    let g:lsfiles_ignore_patterns = get(g:, 'lsfiles_ignore_patterns', [])
    let g:lsfiles_maximum = get(g:, 'lsfiles_maximum', 100)

    let cmd_name = ''
    let rootdir = lsfiles#rootdir#get('.', 'git')
    if isdirectory(rootdir)
        if executable('git')
            let cmd_name = 'git'
        else
            echohl Error
            echo   '[lsfiles] Could not execute git command!'
            echohl None
        endif
    else
        echohl Error
        echo   '[lsfiles] There is not a git repository: ' getcwd()
        echohl None
    endif
    if !empty(cmd_name)
        let winid = popup_menu([], s:get_popupwin_options_main(rootdir, 0))
        let s:subwinid = popup_create('', s:get_popupwin_options_sub(winid, v:true))
        if -1 != winid
            call lsfiles#data#set_cmd_name(rootdir, cmd_name)
            if a:q_bang == '!'
                call lsfiles#data#set_paths(rootdir, [])
                call lsfiles#data#set_query(rootdir, '')
                call lsfiles#data#set_elapsed_time(rootdir, -1.0)
            endif
            call popup_setoptions(winid, {
                \ 'filter': function('s:popup_filter', [rootdir]),
                \ 'callback': function('s:popup_callback', [rootdir]),
                \ })
            call s:search_lsfiles(rootdir, winid)
        endif
    endif
endfunction

function! s:popup_filter(rootdir, winid, key) abort
    let lnum = line('.', a:winid)
    let xs = split(lsfiles#data#get_query(a:rootdir), '\zs')
    if 21 == char2nr(a:key)
        " Ctrl-u
        if 0 < len(xs)
            call remove(xs, 0, -1)
            call lsfiles#data#set_query(a:rootdir, join(xs, ''))
            call s:search_lsfiles(a:rootdir, a:winid)
        endif
        return 1
    elseif (10 == char2nr(a:key)) || (14 == char2nr(a:key))
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
    elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
        " Ctrl-h or bs
        if 0 < len(xs)
            call remove(xs, -1)
            call lsfiles#data#set_query(a:rootdir, join(xs, ''))
            call s:search_lsfiles(a:rootdir, a:winid)
        endif
        return 1
    elseif 0x20 == char2nr(a:key)
        return popup_filter_menu(a:winid, "\<cr>")
    elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
        let xs += [a:key]
        call lsfiles#data#set_query(a:rootdir, join(xs, ''))
        call s:search_lsfiles(a:rootdir, a:winid)
        return 1
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

function! s:get_popupwin_options_main(rootdir, n) abort
    "let elapsed_time = lsfiles#data#get_elapsed_time(a:rootdir)
    let elapsed_time = -1.0
    let opts = {
        \ 'title': printf(' [%s] %d/%d%s ',
        \   fnamemodify(a:rootdir, ':t'),
        \   a:n,
        \   len(lsfiles#data#get_paths(a:rootdir)),
        \   (-1.0 == elapsed_time ? '' : printf(' (elapsed_time: %f)', elapsed_time))),
        \ }
    call utils#popupwin#apply_size(opts)
    call utils#popupwin#apply_border(opts, 'LsFilesPopupBorder')
    return opts
endfunction

function! s:get_popupwin_options_sub(main_winid, hidden) abort
    let pos = popup_getpos(a:main_winid)
    let width = pos['width'] - 2 + pos['scrollbar']
    let opts = {
        \ 'line': pos['line'] - 3,
        \ 'col': pos['col'],
        \ 'width': width,
        \ 'minwidth': width,
        \ 'hidden': a:hidden,
        \ }
    return utils#popupwin#apply_border(opts, 'LsFilesPopupBorder')
endfunction

function! s:can_open_in_current() abort
    let tstatus = term_getstatus(bufnr())
    if (tstatus != 'finished') && !empty(tstatus)
        return v:false
    elseif !empty(getcmdwintype())
        return v:false
    elseif &modified
        return v:false
    else
        return v:true
    endif
endfunction

function! s:popup_callback(rootdir, winid, result) abort
    if -1 != a:result
        let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
        let path = fnamemodify(resolve(a:rootdir .. '/' ..line), ':p:gs?\\?/?')
        if filereadable(path)
            if s:can_open_in_current()
                execute printf('edit %s', fnameescape(path))
            else
                execute printf('new %s', fnameescape(path))
            endif
        endif
    endif
    if -1 != s:subwinid
        call popup_close(s:subwinid)
        let s:subwinid = -1
    endif
endfunction

function! s:filter_query_text(x, y) abort
    try
        " ignore case
        silent! return a:x =~? a:y
    catch
    endtry
    return v:false
endfunction

function! s:search_lsfiles(rootdir, winid) abort
    call popup_settext(a:winid, 'Please wait for listing files in the repository...')
    redraw
    let start_time = reltime()
    let cmd_name = lsfiles#data#get_cmd_name(a:rootdir)
    let query_text = lsfiles#data#get_query(a:rootdir)
    let cmd = ['git', '--no-pager', 'ls-files']
    if empty(lsfiles#data#get_paths(a:rootdir))
        call lsfiles#data#set_paths(a:rootdir, lsfiles#system#exec(cmd, a:rootdir))
    endif
    let filtered_paths = filter(copy(lsfiles#data#get_paths(a:rootdir)), { _, x -> s:filter_query_text(x, query_text) })
    let n = g:lsfiles_maximum - 1
    if n < 1
        let n = 1
    endif
    call popup_settext(a:winid, filtered_paths[:n])
    call lsfiles#data#set_elapsed_time(a:rootdir, reltimefloat(reltime(start_time)))
    call popup_setoptions(a:winid, s:get_popupwin_options_main(a:rootdir, len(filtered_paths)))
    if empty(query_text)
        call popup_hide(s:subwinid)
    else
        call popup_show(s:subwinid)
        call popup_settext(s:subwinid, ' ' .. query_text .. ' ')
        call popup_setoptions(s:subwinid, s:get_popupwin_options_sub(a:winid, v:false))
    endif
endfunction
