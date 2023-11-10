
let s:FT = 'gitdiff-history'
let s:EMPTY = '(empty)'

function! git#diff#history#exec() abort
    try
        let context = git#diff#get_current_context()
        let opts = {
            \ 'title': s:make_title(context),
            \ }
        let xs = s:get_history(context)
        call utils#popupwin#apply_size(opts)
        call utils#popupwin#apply_border(opts, 'VimrcDevPopupBorder')
        let winid = popup_menu(xs, opts)
        call win_execute(winid, 'setfiletype ' .. s:FT)
        call popup_setoptions(winid, {
            \ 'filter': function('s:popup_filter'),
            \ 'callback': function('s:popup_callback'),
            \ })
    catch
        echohl Error
        echo printf('[gitdiff] %s', v:exception)
        echohl None
    endtry
endfunction

function! git#diff#history#exec_first() abort
    let context = git#diff#get_current_context()
    let xs = s:get_history(context)
    if xs[0] == s:EMPTY
        call git#diff#numstat#exec('', '')
    else
        call git#diff#numstat#exec('', xs[0])
    endif
endfunction

function! s:get_history(context) abort
    let xs = map(deepcopy(a:context['history']), { _,x -> empty(x) ? s:EMPTY : x })
    if empty(xs)
        return ['-w']
    else
        return xs
    endif
endfunction

function! s:make_title(context) abort
    return printf(' [%s] %s', s:FT, a:context['rootdir'])
endfunction

function! s:popup_filter(winid, key) abort
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

function! s:popup_callback(winid, result) abort
    if -1 != a:result
        let lnum = a:result
        let q_args = trim(get(getbufline(winbufnr(a:winid), lnum), 0, ''))
        if q_args == s:EMPTY
            call git#diff#numstat#exec('', '')
        else
            call git#diff#numstat#exec('', q_args)
        endif
    endif
endfunction
