
function msbuild#exec(q_args) abort
    let path = fnamemodify(findfile(get(g:, 'msbuild_projectfile', 'msbuild.xml'), ';.'), ':p')
    if filereadable(path)
        let rootdir = fnamemodify(path, ':h')
        let args = trim(a:q_args)
        let cmd = [ ( executable('msbuild')
                \   ? 'msbuild'
                \   : ( has('win32')
                \     ? 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe'
                \     : 'xbuild'
                \     )
                \   ), '/nologo']
        if !empty(args)
            let cmd += split(args, '\s\+')
        endif
        let cmd += [path]
        call jobrunner#new(cmd, rootdir, function('s:close_handler_msbuild', [rootdir, cmd]))
    else
        call jobrunner#error('Can not found msbuild.xml.')
    endif
endfunction

function s:close_handler_msbuild(rootdir, cmd, output)
    let lines = a:output
    call map(lines, { i,x -> sillyiconv#iconv_one_nothrow(x) })
    let xs = []
    let errcnt = 0
    for line in lines
        let dict = {}
        let m = matchlist(line, '^\s*\([^(]*\)(\(\d\+\),\(\d\+\)):\s*\(error\|warning\)\s\+\(.*\)$')
        if !empty(m)
            let fullpath = m[1]
            if !filereadable(fullpath)
                let fullpath = fnamemodify(printf('%s/%s', a:rootdir, m[1]), ':p')
            endif
            if filereadable(fullpath)
                let dict.filename = fullpath
            endif
        endif
        if has_key(dict, 'filename')
            let dict.lnum = m[2]
            let dict.col = m[3]
            if (m[4] == 'error')
                let dict.type = 'E'
                let errcnt += 1
            elseif (m[4] == 'warning')
                let dict.type = 'W'
            endif
            let dict.text = m[5]
        else
            let dict.text = line
        endif
        let xs += [dict]
    endfor
    call setqflist(xs)
    call setqflist([], 'r', { 'title': printf('(%s) %s', a:rootdir, join(a:cmd, ' ')), })
    if 0 < errcnt
        copen
        call jobrunner#error('Build failure.')
    else
        let err = 0
        for line in lines
            if line =~# '\(CSC\|MSBUILD\) : error \(CS\|MSB\)\d\+:'
                let err = 1
                call jobrunner#error(line)
                copen
                break
            endif
        endfor
        if !err
            cclose
            call jobrunner#echo('Build succeeded.')
        endif
    endif
endfunction

