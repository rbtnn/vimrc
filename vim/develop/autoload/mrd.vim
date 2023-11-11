
let s:mrd_path = expand('~/.mrd')
let s:lineinfo_len = 2

function! mrd#exec() abort
    try
        let opts = {
            \ 'title': ' [most recent directories] ',
            \ }
        call utils#popupwin#apply_size(opts)
        call utils#popupwin#apply_border(opts, 'VimrcDevPopupBorder')
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
    call mrd#update_dir()
    let xs = []
    for x in readfile(s:mrd_path)
        let lineinfo = ''
        if s:fix_path(getcwd()) == x
            let lineinfo = '*'
        endif
        let xs += [printf('%-' .. s:lineinfo_len .. 's%s', lineinfo, x)]
    endfor
    return xs
endfunction

function! s:fix_path(x) abort
    return fnamemodify(a:x, ':p:gs!\\!/!')
endfunction

function! s:popup_filter(winid, key) abort
    return utils#popupwin#common_filter(a:winid, a:key)
endfunction

function! s:popup_callback(winid, result) abort
    if -1 != a:result
        let lnum = a:result
        let path = trim(get(getbufline(winbufnr(a:winid), lnum), 0, '')[(s:lineinfo_len - 1):])
        if isdirectory(path)
            lcd .
            call chdir(path)
            verbose pwd
        endif
    endif
endfunction
