
function! helper#echo(msg) abort
    echohl ModeMsg
    echo printf('%s', a:msg)
    echohl None
endfunction

function! helper#error(msg) abort
    echohl ErrorMsg
    echomsg printf('%s', a:msg)
    echohl None
endfunction

function! helper#padding_right_space(text, width)
    return a:text . repeat(' ', a:width - strdisplaywidth(a:text))
endfunction

function! helper#trim(str) abort
    return matchstr(a:str, '^\s*\zs.\{-\}\ze\s*$')
endfunction

function! helper#relines(lines) abort
    let pos = getpos('.')
    let lines = a:lines
    setlocal noreadonly modifiable
    silent % delete _
    silent put=lines
    silent 1 delete _
    setlocal readonly nomodifiable
    setlocal buftype=nofile nolist nocursorline
    call setpos('.', pos)
endfunction

function! helper#new_window(lines) abort
    new
    call helper#relines(a:lines)
    nnoremap <silent><buffer>q       :<C-u>execute ((winnr('$') == 1) ? 'bdelete' : 'quit')<cr>
endfunction

function! helper#modifiers() abort
    return ':p:gs!\!/!'
endfunction

function! helper#open_file(path, lnum) abort
    if filereadable(a:path)
        let fullpath = substitute(fnamemodify(a:path, ':p'), '\', '/', 'g')
        let b = 0
        let saved_wnr = winnr()
        for wnr in range(1, winnr('$'))
            execute wnr . 'wincmd w'
            if expand('%' . helper#modifiers()) is fullpath
                let b = 1
                break
            endif
        endfor
        if !b
            execute saved_wnr . 'wincmd w'
            new
        endif
        if 0 < a:lnum
            execute printf('edit +%d %s', a:lnum, fullpath)
        else
            execute printf('edit %s', fullpath)
        endif
        normal! zz
        return 1
    else
        return 0
    endif
endfunction

