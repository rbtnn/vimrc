
let s:FT = 'gitstatus'

function! git#status#exec() abort
    let opts = {
        \ 'title': printf(' [git] A:"add", R:"restore --staged", D:"diff -w", C:"diff --cached -w" '),
        \ }
    call utils#popupwin#apply_size(opts)
    call utils#popupwin#apply_border(opts, 'VimrcDevPopupBorder')
    let winid = popup_menu([], opts)
    call s:reload_lines(winid)
    call win_execute(winid, 'setfiletype ' .. s:FT)
    call popup_setoptions(winid, {
        \ 'filter': function('s:popup_filter'),
        \ 'callback': function('s:popup_callback'),
        \ })
endfunction

function! s:reload_lines(winid) abort
    let lines = filter(git#internal#system(['status', '-s']), { _,x -> !empty(x) })
    call popup_settext(a:winid, lines)
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
    elseif char2nr('A') == char2nr(a:key)
        call git#internal#system(['add', s:get_current_path(a:winid, lnum)])
        call s:reload_lines(a:winid)
        return 1
    elseif char2nr('C') == char2nr(a:key)
        call git#diff#open_diffwindow(['--cached', '-w'], s:get_current_path(a:winid, lnum))
        return popup_filter_menu(a:winid, "\<esc>")
    elseif char2nr('D') == char2nr(a:key)
        call git#diff#open_diffwindow(['-w'], s:get_current_path(a:winid, lnum))
        return popup_filter_menu(a:winid, "\<esc>")
    elseif char2nr('R') == char2nr(a:key)
        call git#internal#system(['restore', '--staged', s:get_current_path(a:winid, lnum)])
        call s:reload_lines(a:winid)
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

function! s:get_current_path(winid, lnum) abort
    if -1 != a:lnum
        let rootdir = git#internal#get_rootdir()
        let line = get(getbufline(winbufnr(a:winid), a:lnum), 0, '')[3:]
        if -1 != stridx(line, ' -> ')
            let line = split(line, ' -> ')[1]
        endif
        let path = expand(rootdir .. '/' .. line)
        if filereadable(path)
            return path
        endif
    endif
    return ''
endfunction

function! s:popup_callback(winid, result) abort
    let path = s:get_current_path(a:winid, a:result)
    if !empty(path)
        execute printf('edit %s', fnameescape(path))
    endif
endfunction

