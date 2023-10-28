
let s:mrd_path = expand('~/.mrd')

function! mrd#exec() abort
    try
        let opts = {
            \ 'title': ' most recent directories ',
            \ }
        call utils#popupwin#apply_size(opts)
        call utils#popupwin#apply_border(opts, 'GitDiffPopupBorder')
        let winid = popup_menu(mrd#get_directories(), opts)
        call popup_setoptions(winid, {
            \ 'filter': function('s:popup_filter'),
            \ 'callback': function('s:popup_callback'),
            \ })
    catch
        echohl Error
        echo printf('[most recent directories] %s', v:exception)
        echohl None
    endtry
endfunction

function! mrd#update_dir() abort
    let curr = s:fix_path(getcwd())
    let xs = [curr]
    if filereadable(s:mrd_path)
        for x in readfile(s:mrd_path)
            if isdirectory(x) && (-1 == index(xs, x))
                let xs += [x]
            endif
        endfor
    endif
    call writefile(xs[:100], s:mrd_path)
endfunction

function! mrd#get_directories() abort
    if !filereadable(s:mrd_path)
        call mrd#update_dir()
    endif
    return readfile(s:mrd_path)
endfunction

function! s:fix_path(x) abort
    return fnamemodify(a:x, ':p:gs!\\!/!')
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
        let path = trim(get(getbufline(winbufnr(a:winid), lnum), 0, ''))
        if isdirectory(path)
            call chdir(path)
            echo getcwd()
        endif
    endif
endfunction
