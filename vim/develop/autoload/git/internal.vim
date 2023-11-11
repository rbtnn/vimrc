
function! git#internal#echo(text) abort
    echo printf('[git] %s', a:text)
endfunction

function! git#internal#branch_name() abort
    let cwd = git#internal#get_rootdir()
    if !empty(cwd) && filereadable(cwd .. '/.git/HEAD')
        let firstline = get(readfile(cwd .. '/.git/HEAD'), 0, '')
        return split(firstline, '/')[-1]
    else
        return ''
    endif
endfunction

function! git#internal#get_rootdir(path = '.') abort
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

function git#internal#system(subcmd) abort
    let cmd_prefix = ['git', '--no-pager']
    let cwd = git#internal#get_rootdir()
    let lines = []
    if has('nvim')
        let job = jobstart(cmd_prefix + a:subcmd, {
            \ 'cwd': cwd,
            \ 'on_stdout': function('s:system_onevent', [{ 'lines': lines, }]),
            \ 'on_stderr': function('s:system_onevent', [{ 'lines': lines, }]),
            \ })
        call jobwait([job])
    else
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
    endif
    return lines
endfunction



function s:system_onevent(d, job, data, event) abort
    let a:d['lines'] += a:data
    sleep 1m
endfunction

