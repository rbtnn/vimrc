
let s:query_chars = get(s:, 'query_chars', [])

function! ripgrep#files(q_args) abort
    let g:ripgrep_files_maximum = get(g:, 'ripgrep_files_maximum', 100)
    let winid = popup_menu([], s:get_popupwin_options_main())
    if -1 != winid
        call popup_setoptions(winid, {
            \ 'filter': function('s:popup_filter'),
            \ 'callback': function('s:popup_callback'),
            \ })
        call popupwin#set_options(v:false)
        call s:search_lsfiles(winid)
    endif
endfunction

function! s:popup_filter(winid, key) abort
    let lnum = line('.', a:winid)
    let xs = s:query_chars
    if 21 == char2nr(a:key)
        " Ctrl-u
        if 0 < len(xs)
            call remove(xs, 0, -1)
            let s:query_chars = deepcopy(xs)
            call s:search_lsfiles(a:winid)
        endif
        return 1
    elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
        " Ctrl-h or bs
        if 0 < len(xs)
            call remove(xs, -1)
            let s:query_chars = deepcopy(xs)
            call s:search_lsfiles(a:winid)
        endif
        return 1
    elseif (0x21 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
        let xs += [a:key]
        let s:query_chars = deepcopy(xs)
        call s:search_lsfiles(a:winid)
        return 1
    else
        return popupwin#common_filter(a:winid, a:key)
    endif
endfunction

function! s:get_popupwin_options_main() abort
    return {
        \ 'title': printf(' [ripgrep-files] %s ', join(s:query_chars, ''))
        \ }
endfunction

function! s:popup_callback(winid, result) abort
    if -1 != a:result
        let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
        let path = fnamemodify(resolve(line), ':p:gs?\\?/?')
        call fileopener#open_file(path)
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

function! s:search_lsfiles(winid) abort
    let query_text = join(s:query_chars, '')
    call popup_settext(a:winid, 'Please wait for listing files in the repository...')
    redraw
    let xs = []
    let path = tempname()
    try
        let job = job_start(['rg', '--glob', '!NTUSER.DAT*', '--glob', '!.git', '--glob', '!.svn', '--glob', '!node_modules', '--files', '--hidden'], {
            \ 'out_io': 'file',
            \ 'out_name': path,
            \ 'err_io': 'out',
            \ })
        while 'run' == job_status(job)
        endwhile
        if filereadable(path)
            let xs = filter(readfile(path), { _, x -> s:filter_query_text(x, query_text) })
        endif
    finally
        if filereadable(path)
            call delete(path)
        endif
    endtry
    let n = g:ripgrep_files_maximum < 1 ? 1 : g:ripgrep_files_maximum
    call popup_settext(a:winid, xs[:(n - 1)])
    call popup_setoptions(a:winid, s:get_popupwin_options_main())
    call win_execute(a:winid, 'call clearmatches()')
    if !empty(query_text)
        call win_execute(a:winid, printf('silent call matchadd(''Search'', ''%s'')', '\c' .. query_text))
    endif
endfunction
