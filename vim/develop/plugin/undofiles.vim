
let g:loaded_develop_undofiles = 1

if isdirectory(&undodir)
    command! -nargs=* UndofilesClean      :call s:undofiles_clean()

    function! s:undofiles_clean() abort
        for undofile_path in split(globpath(&undodir, '*'), '\n') + split(globpath(&undodir, '*.*'), '\n')
            let real_path = substitute(substitute(fnamemodify(undofile_path, ':t'), '^\([A-Z]\)%%', '\1:%', ''), '%', '/', 'g')
            if !filereadable(real_path) && (undofile_path =~# '^' .. escape(&undodir, '\'))
                echo undofile_path
                call delete(undofile_path)
            endif
        endfor
    endfunction
endif
