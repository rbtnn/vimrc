
function s:echo(msg) abort
    echohl ModeMsg
    echo printf('%s', a:msg)
    echohl None
endfunction

function s:error(msg) abort
    echohl ErrorMsg
    echomsg printf('%s', a:msg)
    echohl None
endfunction

function s:iconv_one_nothrow(x) abort
    let x = a:x
    try
        let x = diffy#sillyiconv#iconv_one_nothrow(x)
    catch
    endtry
    return x
endfunction

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
        let out_path = tempname()
        let job = job_start(cmd, {
                \ 'close_cb' : function('s:close_handler_msbuild', [out_path, rootdir, cmd]),
                \ 'cwd' : s:iconv_one_nothrow(rootdir),
                \ 'out_io' : 'file',
                \ 'out_name' : out_path,
                \ })
    else
        call s:error('Can not found msbuild.xml.')
    endif
endfunction

function s:close_handler_msbuild(out_path, rootdir, cmd, channel)
    let lines = readfile(a:out_path)
    call map(lines, { i,x -> s:iconv_one_nothrow(x) })
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
        call s:error('Build failure.')
    else
        let err = 0
        for line in lines
            if line =~# '\(CSC\|MSBUILD\) : error \(CS\|MSB\)\d\+:'
                let err = 1
                call s:error(line)
                copen
                break
            endif
        endfor
        if !err
            cclose
            call s:echo('Build succeeded.')
        endif
    endif
    for p in [(a:out_path)]
        if filereadable(p)
            call delete(p)
        endif
    endfor
endfunction

