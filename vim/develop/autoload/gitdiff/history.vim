
let s:FT = 'gitdiff-history'
let s:EMPTY = '(empty)'

function! gitdiff#history#exec() abort
    try
        let context = gitdiff#get_current_context()
        if empty(context['history'])
            throw 'No history!'
        endif
        let opts = {
            \ 'title': s:make_title(context),
            \ }
        call gitdiff#popupwin#apply_size(opts)
        call gitdiff#popupwin#apply_border(opts, 'GitDiffPopupBorder')
        let winid = popup_menu(map(deepcopy(context['history']), { _,x -> empty(x) ? s:EMPTY : x }), opts)
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

function! s:make_title(context) abort
    return printf(' [%s] %s', s:FT, a:context['rootdir'])
endfunction

function! s:popup_filter(winid, key) abort
    let lnum = line('.', a:winid)
    if (10 == char2nr(a:key)) || (14 == char2nr(a:key))
        " Ctrl-n or Ctrl-j
        if lnum == line('$', a:winid)
            call gitdiff#popupwin#set_cursorline(a:winid, 1)
        else
            call gitdiff#popupwin#set_cursorline(a:winid, lnum + 1)
        endif
        return 1
    elseif (11 == char2nr(a:key)) || (16 == char2nr(a:key))
        " Ctrl-p or Ctrl-k
        if lnum == 1
            call gitdiff#popupwin#set_cursorline(a:winid, line('$', a:winid))
        else
            call gitdiff#popupwin#set_cursorline(a:winid, lnum - 1)
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
            call gitdiff#numstat#exec('', '')
        else
            call gitdiff#numstat#exec('', q_args)
        endif
    endif
endfunction
