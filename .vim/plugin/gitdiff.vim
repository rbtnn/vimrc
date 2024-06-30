if executable('git')
    command! -nargs=0 GitShow :call s:git_show()

    function! s:git_show() abort
        let rootdir = s:git_get_rootdir()
        if isdirectory(rootdir)
            let curr_ftype = &filetype
            let curr_fname = expand("%:t")
            for w in filter(getwininfo(), { _, x -> x['tabnr'] == tabpagenr() })
                if &diff
                    call win_execute(w['winid'], 'diffoff')
                endif
                if getbufvar(w['bufnr'], 'gitshow_scratch', 0)
                    call win_execute(w['winid'], 'close')
                endif
            endfor
            for path in s:git_system(['ls-files', '*' .. curr_fname])
                diffthis
                let lines = s:git_system(['show', '@~0:' .. path])
                vnew
                let b:gitshow_scratch = 1
                setlocal modifiable noreadonly
                call setbufline(bufnr(), 1, lines)
                setlocal buftype=nofile nomodifiable readonly
                let &l:filetype = curr_ftype
                diffthis
                break
            endfor
        else
            echohl Error
            echo '[git] The directory is not under git control!'
            echohl None
        endif
    endfunction

    function! s:git_get_rootdir(path = '.') abort
        let xs = split(fnamemodify(a:path, ':p'), '[\/]')
        let prefix = (has('mac') || has('linux')) ? '/' : ''
        while !empty(xs)
            let path = prefix .. join(xs + ['.git'], '/')
            if isdirectory(path) || filereadable(path)
                return prefix .. join(xs, '/')
            endif
            call remove(xs, -1)
        endwhile
        return ''
    endfunction

    function s:git_system(subcmd) abort
        let cmd_prefix = ['git', '--no-pager']
        let cwd = s:git_get_rootdir()
        let lines = []
        let path = tempname()
        try
            let job = job_start(cmd_prefix + a:subcmd, {
                \ 'cwd': cwd,
                \ 'out_io': 'file',
                \ 'out_name': path,
                \ 'err_io': 'out',
                \ })
            while 'run' == job_status(job)
            endwhile
            if filereadable(path)
                let lines = readfile(path)
            endif
        finally
            if filereadable(path)
                call delete(path)
            endif
        endtry
        return lines
    endfunction
endif
