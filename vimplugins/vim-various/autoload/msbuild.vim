
function! msbuild#exec(q_args) abort
    let args = helper#trim(a:q_args)
    let cmd = [(has('win32')
            \ ? 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe'
            \ : 'xbuild'), '/nologo']
    if !empty(args)
        let cmd += split(args, '\s\+')
    endif
    if empty(a:q_args)
        let cmd += [findfile('msbuild.xml', ';.')]
    endif
    call job#new(cmd, getcwd(), function('s:close_handler_msbuild', [getcwd(), (cmd)]))
endfunction

function! s:close_handler_msbuild(path, cmd, output)
    let lines = a:output
    call map(lines, { i,x -> sillyiconv#iconv_one_nothrow(x) })
    let xs = []
    let errcnt = 0
    for line in lines
        let dict = {}
        let m = matchlist(line, '^\s*\(.*\)(\(\d\+\),\(\d\+\)):\(.*\)$')
        if !empty(m)
            if filereadable(m[1])
                let dict.filename = fnamemodify(m[1], ':p')
                let errcnt += 1
            endif
        endif
        if has_key(dict, 'filename')
            let dict.lnum = m[2]
            let dict.col = m[3]
            let dict.text = m[4]
        else
            let dict.text = line
        endif
        let xs += [dict]
    endfor
    call setqflist(xs)
    call setqflist([], 'r', { 'title': printf('(%s) %s', a:path, join(a:cmd, ' ')), })
    if 0 < errcnt
        call helper#error('Build failure.')
    else
        let not_exists = 0
        for line in lines
            if line =~# 'MSBUILD : error MSB1009:'
                let not_exists = 1
                call helper#error(line)
                break
            endif
        endfor
        if !not_exists
            call helper#echo('Build succeeded.')
        endif
    endif
endfunction

