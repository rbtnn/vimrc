
if has('win32')
    let g:vimrc_vcvarsall_batpath = get(g:, 'vimrc_vcvarsall_batpath', 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat')
    function! s:VcvarsallTerminal(q_args) abort
        call term_start(['cmd.exe', '/nologo', '/k', g:vimrc_vcvarsall_batpath, empty(a:q_args) ? 'x86' : a:q_args], {
            \ })
    endfunction
    if filereadable(g:vimrc_vcvarsall_batpath)
        command! -nargs=?     VcvarsallTerminal           :call s:VcvarsallTerminal(<q-args>)
    endif
endif
