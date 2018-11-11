
let g:loaded_vimbuild = 1

let s:saved_path = ''
let s:saved_include = ''
let s:saved_lib = ''

let s:makefile = 'Make_mvc.mak'
let s:msvcdir = 'C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/VC/Tools/MSVC'
let s:winkitslibdir = 'C:/Program Files (x86)/Windows Kits/10/lib'
let s:winkitsincdir = 'C:/Program Files (x86)/Windows Kits/10/Include'
let s:sdkdir = 'C:/Program Files (x86)/Microsoft SDKs/Windows/v7.1A'
let s:msvcdir = get(split(globpath(s:msvcdir, '*'), '\n'), -1, '')
let s:winkitslibdir2 = get(split(globpath(s:winkitslibdir, '*'), '\n'), -1, '')
let s:winkitsincdir2 = get(split(globpath(s:winkitsincdir, '*'), '\n'), -1, '')

let s:path_list = [
        \ expand(s:msvcdir . '/bin/Hostx86/x86'),
        \ expand(s:sdkdir . '/Bin'),
        \ ]
let s:include_list = [
        \ expand(s:msvcdir . '/include'),
        \ expand(s:sdkdir . '/Include'),
        \ expand(s:winkitsincdir2 . '/ucrt'),
        \ expand(s:winkitsincdir2 . '/um'),
        \ ]
let s:lib_list = [
        \ expand(s:msvcdir . '/ATLMFC/lib/x86'),
        \ expand(s:msvcdir . '/lib/x86'),
        \ expand(s:winkitslibdir2 . '/ucrt/x86'),
        \ expand(s:winkitslibdir2 . '/um/x86'),
        \ ]

let s:checkingpath_list = [
        \ expand(s:winkitslibdir),
        \ expand(s:winkitsincdir),
        \ ] + (s:path_list + s:include_list + s:lib_list)

let s:your_path_list = get(s:, 'your_path_list', split($PATH, ';'))

function! s:enabled_vimbuild() abort
    let ok = v:true
    if filereadable(s:makefile)
        for dir in s:checkingpath_list
            if !isdirectory(dir)
                call helper#error('No such directory: ' . dir)
                let ok = v:false
                break
            endif
        endfor
    else
        call helper#error('No such file: ' . s:makefile)
        let ok = v:false
    endif
    return ok
endfunction

function! s:vimbuild(q_args) abort
    if s:enabled_vimbuild()
        call setqflist([])
        let s:saved_path = $PATH
        let s:saved_include = $INCLUDE
        let s:saved_lib = $LIB
        let $PATH = join(s:path_list + s:your_path_list, ';')
        let $INCLUDE = join(s:include_list, ';')
        let $LIB = join(s:lib_list, ';')
        if has('win32')
            let cmd = ['nmake.exe']
            let cmd += [
                    \ '-f', s:makefile,
                    \ 'IME=yes', 'MBYTE=yes', 'ICONV=yes', 'CSCOPE=yes', 'DEBUG=no', 'DIRECTX=yes',
                    \ 'NETBEANS=no', 'PLATFORM=x86', 'XPM=no', 'USE_MSVCRT=1', 'TERMINAL=yes', 'GUI=yes',
                    \ ('SDK_INCLUDE_DIR=' . expand(s:sdkdir . '/Include')),
                    \ ]
            let cmd += split(a:q_args, '\s\+')
            call job#new(cmd, getcwd(), function('s:close_handler_vimbuild', [getcwd(), cmd]))
        endif
    endif
endfunction

function! s:gvimopen(q_args) abort
    if s:enabled_vimbuild()
        !start ./gvim.exe
    endif
endfunction

function! s:close_handler_vimbuild(path, cmd, output)
    try
        let lines = a:output
        let xs = []
        let errcnt = 0
        for line in lines
            let line = sillyiconv#iconv_one_nothrow(line[:1024])
            let line = substitute(line, "[\n\r\t]", ' ', 'g')
            let dict = {}
            let m1 = matchlist(line, '^\(.*\)(\(\d\+\)): \(\(error\|warning\) \(C\d\+\): .*\)$')
            let m2 = matchlist(line, '^\(.*\)(\(\d\+\)): \(note: .*\)$')
            let m3 = matchlist(line, '^NMAKE : fatal error .*$')
            if !empty(m1)
                if m1[5] !=# 'C4005'
                    if filereadable(m1[1])
                        let dict.filename = fnamemodify(m1[1], ':p')
                    endif
                    let dict.lnum = m1[2]
                    let dict.col = 1
                    let dict.text = m1[3]
                    if m1[4] ==# 'error'
                        let errcnt += 1
                    endif
                endif
            elseif !empty(m2)
                if filereadable(m2[1])
                    let dict.filename = fnamemodify(m2[1], ':p')
                endif
                let dict.lnum = m2[2]
                let dict.col = 1
                let dict.text = m2[3]
            elseif !empty(m3)
                let errcnt += 1
                let dict.text = line
            else
                let dict.text = line
            endif
            let xs += [dict]
        endfor
        call setqflist(xs)
        if 0 < errcnt
            call helper#error('Build failure.')
        else
            call helper#echo('Build succeeded.')
        endif
    finally
        let $PATH = s:saved_path
        let $INCLUDE = s:saved_include
        let $LIB = s:saved_lib
    endtry
endfunction

command! -nargs=* VimBuild           :call <SID>vimbuild(<q-args>)
command! -nargs=* VimBuildWithClpum  :call <SID>vimbuild('CLPUM=yes')
command! -nargs=* VimGVimOpen        :call <SID>gvimopen(<q-args>)

