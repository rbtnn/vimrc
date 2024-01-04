
function! git#lsfiles#exec(q_bang) abort
    let rootdir = git#internal#get_rootdir()
    let winid = popup_menu([], s:get_popupwin_options_main(rootdir))
    if -1 != winid
        if a:q_bang == '!'
            call git#lsfiles#data#set_paths(rootdir, [])
            call git#lsfiles#data#set_query(rootdir, '')
        endif
        call popup_setoptions(winid, {
            \ 'filter': function('s:popup_filter', [rootdir]),
            \ 'callback': function('s:popup_callback', [rootdir]),
            \ })
        call utils#popupwin#set_options(v:false)
        call s:search_lsfiles(rootdir, winid)
    endif
endfunction

function! s:popup_filter(rootdir, winid, key) abort
    let lnum = line('.', a:winid)
    let xs = split(git#lsfiles#data#get_query(a:rootdir), '\zs')
    if 21 == char2nr(a:key)
        " Ctrl-u
        if 0 < len(xs)
            call remove(xs, 0, -1)
            call git#lsfiles#data#set_query(a:rootdir, join(xs, ''))
            call s:search_lsfiles(a:rootdir, a:winid)
        endif
        return 1
    elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
        " Ctrl-h or bs
        if 0 < len(xs)
            call remove(xs, -1)
            call git#lsfiles#data#set_query(a:rootdir, join(xs, ''))
            call s:search_lsfiles(a:rootdir, a:winid)
        endif
        return 1
    elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
        let xs += [a:key]
        call git#lsfiles#data#set_query(a:rootdir, join(xs, ''))
        call s:search_lsfiles(a:rootdir, a:winid)
        return 1
    else
        return utils#popupwin#common_filter(a:winid, a:key)
    endif
endfunction

function! s:get_popupwin_options_main(rootdir) abort
    let query_text = git#lsfiles#data#get_query(a:rootdir)
    let opts = {
        \ 'title': printf(' %s ', query_text)
        \ }
    return opts
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
    let query_text = git#lsfiles#data#get_query(a:rootdir)
    if empty(git#lsfiles#data#get_paths(a:rootdir))
        call git#lsfiles#data#set_paths(a:rootdir, git#internal#system(['ls-files']))
    endif
    let filtered_paths = filter(copy(git#lsfiles#data#get_paths(a:rootdir)), { _, x -> s:filter_query_text(x, query_text) })
    let n = g:git_lsfiles_maximum - 1
    if n < 1
        let n = 1
    endif
    call popup_settext(a:winid, filtered_paths[:n])
    call popup_setoptions(a:winid, s:get_popupwin_options_main(a:rootdir))
    if g:git_enabled_match_query
        call win_execute(a:winid, 'call clearmatches()')
    endif
    if !empty(query_text)
        if g:git_enabled_match_query
            call win_execute(a:winid, printf('silent call matchadd(''Search'', ''%s'')', '\c' .. query_text))
        endif
    endif
endfunction
