
const s:padding_width = 2
const s:hlname1 = 'VimrcDevPopupWin'
const s:hlname2 = 'Search'

let s:curr_job = get(s:, 'curr_job', v:null)
let s:match_items = get(s:, 'match_items', [])

let s:executor_id2query = get(s:, 'executor_id2query', {})
let s:executor_id2title = get(s:, 'executor_id2title', {})
let s:executor_id2prefixcmd = get(s:, 'executor_id2prefixcmd', {})
let s:executor_id2postcmd = get(s:, 'executor_id2postcmd', {})
let s:executor_id2maximum = get(s:, 'executor_id2maximum', {})
let s:executor_id2ignores = get(s:, 'executor_id2ignores', {})
let s:executor_id2withquery = get(s:, 'executor_id2withquery', {})

function! ripgrep#common#exec(executor_id, title, prefix_cmd, post_cmd, withquery, callback, ignores, maximum) abort
    let s:executor_id2query[a:executor_id] = get(s:executor_id2query, a:executor_id, [])
    let s:executor_id2title[a:executor_id] = a:title
    let s:executor_id2prefixcmd[a:executor_id] = a:prefix_cmd
    let s:executor_id2postcmd[a:executor_id] = a:post_cmd
    let s:executor_id2maximum[a:executor_id] = a:maximum
    let s:executor_id2ignores[a:executor_id] = a:ignores
    let s:executor_id2withquery[a:executor_id] = a:withquery
    if executable('rg') && !executable('nvim')
        let winid = popup_menu([], s:get_title_option(a:executor_id))
        if -1 != winid
            let maxwidth = &columns - s:padding_width - s:get_tabsidebarcolumns()
            let maxheight = &lines - 1 - &cmdheight
            call popup_setoptions(winid, {
                \ 'filter': function('s:popup_filter', [a:executor_id]),
                \ 'callback': function('s:popup_callback', [a:callback]),
                \ 'highlight': s:hlname1,
                \ 'border': [0, 0, 0, 0],
                \ 'padding': [0, 1, 0, 1],
                \ 'wrap': 0,
                \ 'minwidth': maxwidth, 'maxwidth': maxwidth,
                \ 'minheight': maxheight, 'maxheight': maxheight,
                \ 'line': 1,
                \ 'col': 1,
                \ 'pos': 'topleft',
                \ })
            call s:job_runner(winid, a:executor_id, get(s:executor_id2query, a:executor_id, []))
        endif
    endif
endfunction

function! s:get_title_option(executor_id) abort
    return {
        \ 'title': printf(' %s>%s ', s:executor_id2title[a:executor_id], join(s:executor_id2query[a:executor_id], ''))
        \ }
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

function! s:popup_filter(executor_id, winid, key) abort
    let lnum = line('.', a:winid)
    let xs = s:executor_id2query[a:executor_id]
    if 21 == char2nr(a:key)
        " Ctrl-u
        if 0 < len(xs)
            call remove(xs, 0, -1)
            call s:job_runner(a:winid, a:executor_id, xs)
        endif
        return 1
    elseif ("\x80kb" == a:key) || (8 == char2nr(a:key))
        " Ctrl-h or bs
        if 0 < len(xs)
            call remove(xs, -1)
            call s:job_runner(a:winid, a:executor_id, xs)
        endif
        return 1
    elseif (0x20 <= char2nr(a:key)) && (char2nr(a:key) <= 0x7f)
        call s:job_runner(a:winid, a:executor_id, xs + [a:key])
        return 1
    elseif 22 == char2nr(a:key)
        " Ctrl-v
        call s:job_runner(a:winid, a:executor_id, xs + split(@", '\zs'))
        return 1
    elseif (10 == char2nr(a:key)) || (14 == char2nr(a:key))
        " Ctrl-n or Ctrl-j
        if lnum == line('$', a:winid)
            call s:set_cursorline(a:winid, 1)
        else
            call s:set_cursorline(a:winid, lnum + 1)
        endif
        return 1
    elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key))
        " Ctrl-p or Ctrl-k
        if lnum == 1
            call s:set_cursorline(a:winid, line('$', a:winid))
        else
            call s:set_cursorline(a:winid, lnum - 1)
        endif
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

function! s:popup_callback(callback, winid, result) abort
    if -1 != a:result
        let line = trim(get(getbufline(winbufnr(a:winid), a:result), 0, ''))
        call a:callback(line)
    endif
endfunction

function! s:job_runner(winid, executor_id, query) abort
    call win_execute(a:winid, 'call clearmatches()')
    let s:executor_id2query[a:executor_id] = a:query
    let query_text = join(s:executor_id2query[a:executor_id], '')
    if !empty(query_text)
        call win_execute(a:winid, printf('silent call matchadd(''' .. s:hlname2 .. ''', ''%s'')', '\c' .. query_text))
    endif
    call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
    redraw
    let s:match_items = []
    call popup_settext(a:winid, s:match_items)
    call s:kill_job(a:winid)
    if !empty(query_text)
        let cmd = s:executor_id2prefixcmd[a:executor_id] + (s:executor_id2withquery[a:executor_id] ? [query_text] : []) + s:executor_id2postcmd[a:executor_id]
        let s:curr_job = job_start(cmd, {
            \ 'out_io': 'pipe',
            \ 'out_cb': function('s:out_cb', [a:winid, a:executor_id]),
            \ 'close_cb': function('s:close_cb', [a:winid, a:executor_id]),
            \ 'err_io': 'out',
            \ })
    endif
endfunction

function! s:kill_job(winid) abort
    if (v:null != s:curr_job) && ('run' == job_status(s:curr_job))
        call job_stop(s:curr_job, 'kill')
        let s:curr_job = v:null
    endif
endfunction

function! s:out_cb(winid, executor_id, ch, msg) abort
    let query_text = join(s:executor_id2query[a:executor_id], '')
    try
        if (-1 == index(popup_list(), a:winid)) || (s:executor_id2maximum[a:executor_id] <= len(s:match_items))
            " kill the job if close the popup window
            call s:kill_job(a:winid)
        else
            " ignore case
            if a:msg =~? query_text
                let ok = v:true
                for pat in s:executor_id2ignores[a:executor_id]
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
            call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
        endif
    catch
        echo v:exception
    endtry
endfunction

function! s:close_cb(winid, executor_id, ch) abort
    call popup_setoptions(a:winid, s:get_title_option(a:executor_id))
endfunction

function! s:set_cursorline(winid, lnum) abort
    call win_execute(a:winid, printf('call setpos(".", [0, %d, 0, 0])', a:lnum))
    call win_execute(a:winid, 'redraw')
endfunction
