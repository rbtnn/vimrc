
let g:loaded_develop_msbuild = 1

if has('win32') && executable('msbuild')
    command! -nargs=* -complete=customlist,MSBuildRunTaskComp   MSBuild      :call s:msbuild(eval(g:msbuild_projectfile), <q-args>)

    let g:msbuild_projectfile = get(g:, 'msbuild_projectfile', "findfile('msbuild.xml', ';')")

    function! s:msbuild(projectfile, args) abort
        if type([]) == type(a:args)
            let cmd = ['msbuild']
            if filereadable(a:projectfile)
                let cmd += ['/nologo', a:projectfile] + a:args
            else
                let cmd += ['/nologo'] + a:args
            endif
        else
            let cmd = printf('msbuild /nologo %s "%s"', a:args, a:projectfile)
        endif
        call qfjob#start(cmd, {
            \ 'title': 'msbuild',
            \ 'line_parser': function('s:line_parser', [a:projectfile]),
            \ })
    endfunction

    function s:line_parser(projectfile, line) abort
        let m = matchlist(a:line, '^\s*\([^(]\+\)(\(\d\+\),\(\d\+\)): \(.*\)$')
        if !empty(m)
            let path = m[1]
            if !filereadable(path) && (path !~# '^[A-Z]:')
                let path = expand(fnamemodify(a:projectfile, ':h') .. '/' .. m[1])
            endif
            return {
                \ 'filename': iconv#exec(path),
                \ 'lnum': m[2],
                \ 'col': m[3],
                \ 'text': iconv#exec(m[4]),
                \ }
        else
            return { 'text': iconv#exec(a:line), }
        endif
    endfunction

    function! MSBuildRunTaskComp(A, L, P) abort
        let xs = []
        let path = eval(g:msbuild_projectfile)
        if filereadable(path)
            for line in readfile(path)
                let m = matchlist(line, '<Target\s\+Name="\([^"]\+\)"')
                if !empty(m)
                    let xs += ['/t:' .. m[1]]
                endif
            endfor
        endif
        return xs
    endfunction
endif

