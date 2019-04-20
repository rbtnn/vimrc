
scriptversion 3

function! vimscript#run() abort
    let in_path = tempname()
    let out_path = tempname()
    call writefile(getbufline('%', 1, '$'), in_path)
    let vim = expand('~/Desktop/vim/src/vim')
    if !filereadable(vim) && executable('vim')
        let vim = 'vim'
    endif
    let cmd = [vim, '-X', '-N', '-u', 'NONE', '-i', 'NONE', '-V1', '-e', '-s', '-S', in_path, '+qall!']
    let job = job_start(cmd, {
        \ 'close_cb' : function('s:handler_close_cb', [in_path, out_path]),
        \ 'err_io' : 'file',
        \ 'err_name' : out_path,
        \ })
endfunction

function! s:handler_close_cb(in_path, out_path, channel) abort
    call s:new_window(readfile(a:out_path))
    for p in [(a:in_path), (a:out_path)]
        if filereadable(p)
            call delete(p)
        endif
    endfor
endfunction

function s:new_window(lines) abort
    new
    let pos = getpos('.')
    let lines = a:lines
    setlocal noreadonly modifiable
    silent % delete _
    silent put=lines
    silent 1 delete _
    setlocal readonly nomodifiable
    setlocal buftype=nofile nolist nocursorline
    call setpos('.', pos)
    nnoremap <silent><buffer>q       :<C-u>execute ((winnr('$') == 1) ? 'bdelete' : 'quit')<cr>
endfunction
