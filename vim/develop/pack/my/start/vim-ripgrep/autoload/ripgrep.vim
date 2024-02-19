
let s:query_chars = get(s:, 'query_chars', [])
let s:curr_job = get(s:, 'curr_job', v:null)
let s:match_items = get(s:, 'match_items', [])

function! ripgrep#init() abort
    let g:ripgrep_files_maximum = get(g:, 'ripgrep_files_maximum', 100)
    let g:ripgrep_glob_args = get(g:, 'ripgrep_glob_args', [
        \ '--glob', '!NTUSER.DAT*',
        \ '--glob', '!.git',
        \ '--glob', '!.svn',
        \ '--glob', '!bin',
        \ '--glob', '!obj',
        \ '--glob', '!node_modules',
        \ '--line-buffered'
        \ ])
    let g:ripgrep_ignore_patterns = get(g:, 'ripgrep_ignore_patterns', [
        \ 'min.js$', 'min.js.map$', 'Thumbs.db$',
        \ ])
endfunction

function! ripgrep#search(q_args) abort
    call ripgrep#init()
    let cmd = ['rg'] + g:ripgrep_glob_args + ['--vimgrep', '-uu'] + split(a:q_args, '\s\+') + (has('win32') ? ['.\'] : ['.'])
    call qfjob#start(cmd, {
        \ 'title': 'ripgrep',
        \ 'line_parser': function('s:line_parser'),
        \ })
endfunction

function! ripgrep#files(q_args) abort
    call ripgrep#init()
    let winid = popup_menu([], s:get_title_option())
    if -1 != winid
        call popup_setoptions(winid, {
            \ 'filter': function('s:popup_filter'),
            \ 'callback': function('s:popup_callback'),
            \ })
        call popupwin#set_options(v:false)
        call s:search_lsfiles(winid)
    endif
endfunction

function s:line_parser(line) abort
    let m = matchlist(a:line, '^\s*\(.\{-\}\):\(\d\+\):\(\d\+\):\(.*\)$')
    if !empty(m)
        let path = m[1]
        if !filereadable(path) && (path !~# '^[A-Z]:')
            let path = expand(fnamemodify(m[5], ':h') .. '/' .. m[1])
        endif
        let ok = v:true
        for pat in g:ripgrep_ignore_patterns
            if path =~# pat
                let ok = v:false
                break
            endif
        endfor
        if ok
            return {
                \ 'filename': iconv#exec(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': iconv#exec(m[4]),
                \ }
        else
            return {}
        endif
    else
        return { 'text': iconv#exec(a:line), }
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

function! s:get_title_option() abort
    let status = 'dead'
    if v:null != s:curr_job
        let status = job_status(s:curr_job)
    endif
    return {
        \ 'title': printf(' [ripgrep-files] job:%s, matches:%d, query:"%s" ', status, len(s:match_items), join(s:query_chars, ''))
        \ }
endfunction

function! s:popup_callback(winid, result) abort
    if -1 != a:result
        let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
        let path = fnamemodify(resolve(line), ':p:gs?\\?/?')
        call fileopener#open_file(path)
    endif
endfunction

function! s:kill_job(winid) abort
    if (v:null != s:curr_job) && ('run' == job_status(s:curr_job))
        call job_stop(s:curr_job, 'kill')
        let s:curr_job = v:null
    endif
endfunction

function! s:search_lsfiles(winid) abort
    call win_execute(a:winid, 'call clearmatches()')
    let query_text = join(s:query_chars, '')
    if !empty(query_text)
        call win_execute(a:winid, printf('silent call matchadd(''Search'', ''%s'')', '\c' .. query_text))
    endif
    redraw
    let s:match_items = []
    call popup_settext(a:winid, s:match_items)
    call s:kill_job(a:winid)
    let s:curr_job = job_start(['rg'] + g:ripgrep_glob_args + ['--files', '--hidden'], {
        \ 'out_io': 'pipe',
        \ 'out_cb': function('s:out_cb', [a:winid]),
        \ 'close_cb': function('s:close_cb', [a:winid]),
        \ 'err_io': 'out',
        \ })
endfunction

function! s:out_cb(winid, ch, msg) abort
    let query_text = join(s:query_chars, '')
    try
        if (-1 == index(popup_list(), a:winid)) || (g:ripgrep_files_maximum <= len(s:match_items))
            " kill the job if close the popup window
            call s:kill_job(a:winid)
        else
            " ignore case
            if a:msg =~? query_text
                let ok = v:true
                for pat in g:ripgrep_ignore_patterns
                    if a:msg =~# pat
                        let ok = v:false
                        break
                    endif
                endfor
                if ok
                    let s:match_items += [a:msg]
                    call popup_settext(a:winid, s:match_items)
                endif
            endif
            call popup_setoptions(a:winid, s:get_title_option())
        endif
    catch
        echo v:exception
    endtry
endfunction

function! s:close_cb(winid, ch) abort
    call popup_setoptions(a:winid, s:get_title_option())
endfunction
