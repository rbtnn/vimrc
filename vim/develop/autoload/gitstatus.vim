
let s:FT = 'gitstatus'

function! gitstatus#exec() abort
    try
        let opts = {
            \ 'title': printf(' [%s] A:add, C:checkout, D:diff ', s:FT),
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
    catch
        echohl Error
        echo printf('[%s] %s', s:FT, v:exception)
        echohl None
    endtry
endfunction

function! s:reload_lines(winid) abort
    let rootdir = gitdiff#rootdir#get()
    let lines = filter(utils#system#exec('git --no-pager status -s', rootdir), { _,x -> !empty(x) })
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
    elseif 65 == char2nr(a:key)
        " A
        let rootdir = gitdiff#rootdir#get()
        call utils#system#exec(printf('git --no-pager add "%s"', s:get_current_path(a:winid, lnum)), rootdir)
        call s:reload_lines(a:winid)
        return 1
    elseif 67 == char2nr(a:key)
        " C
        echo 'git checkout '
        return 1
    elseif 68 == char2nr(a:key)
        " D
        echo 'git diff '
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
        let rootdir = gitdiff#rootdir#get()
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

