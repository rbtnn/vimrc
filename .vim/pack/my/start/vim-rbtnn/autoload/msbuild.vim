
if exists(':scriptversion')
    scriptversion 3
else
    finish
endif

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

function msbuild#new(q_args) abort
    let msbuild_lines = [
            \ '<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" DefaultTargets="BuildMain">',
            \ '',
            \ '    <PropertyGroup>',
            \ '        <MainAssemblyName>Main.exe</MainAssemblyName>',
            \ '        <OutputPath>bin\</OutputPath>',
            \ '    </PropertyGroup>',
            \ '',
            \ '    <ItemGroup>',
            \ '        <CompileMain Include="src\*.cs" />',
            \ '    </ItemGroup>',
            \ '',
            \ '    <Target Name="Configure">',
            \ '        <MakeDir Directories="$(OutputPath)" Condition="!Exists(''$(OutputPath)'')" />',
            \ '    </Target>',
            \ '',
            \ '    <Target Name="BuildMain" DependsOnTargets="Configure">',
            \ '        <Csc Sources="@(CompileMain)" TargetType="exe"     OutputAssembly="$(OutputPath)$(MainAssemblyName)" />',
            \ '    </Target>',
            \ '',
            \ '    <Target Name="Clean">',
            \ '        <RemoveDir Directories="$(OutputPath)" />',
            \ '    </Target>',
            \ '',
            \ '</Project>',
            \ ]
    let main_lines = [
            \ 'using System;',
            \ 'using System.Collections.Generic;',
            \ 'using System.IO;',
            \ 'using System.Linq;',
            \ 'using System.Text.RegularExpressions;',
            \ 'using System.Text;',
            \ '',
            \ 'public class Program',
            \ '{',
            \ '    public static void Main()',
            \ '    {',
            \ '        Console.WriteLine(@"hi");',
            \ '    }',
            \ '}',
            \ ]
    let projectname = a:q_args
    if projectname !~# '^[a-zA-Z0-9-_.]\+$'
        call s:error(projectname .. ' is an invalid name.')
        return
    endif
    if isdirectory(projectname)
        call s:error(projectname .. ' already exists.')
        return
    endif
    call mkdir(projectname)
    call writefile(msbuild_lines, projectname .. '/msbuild.xml')
    call mkdir(projectname .. '/src')
    call writefile(main_lines, projectname .. '/src/Main.cs')
    execute printf('new %s/src/Main.cs', projectname)
    execute printf('lcd %s', projectname)
endfunction

function msbuild#run(q_args) abort
    let path = fnamemodify(findfile(get(g:, 'msbuild_projectfile', 'msbuild.xml'), ';.'), ':p')
    if filereadable(path)
        let rootdir = fnamemodify(path, ':h')
        let exepath = glob(rootdir .. '/bin/*.exe')
        if filereadable(exepath)
            execute printf('terminal %s "%s"', (has('win32') ? '' : 'mono'), exepath)
        else
            call s:error('Could not find executable file.')
        endif
    else
        call s:error('Could not find msbuild.xml.')
    endif
endfunction

function msbuild#build(q_args) abort
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
                \ 'close_cb' : function('s:close_handler_msbuild_build', [out_path, rootdir, cmd]),
                \ 'cwd' : s:iconv_one_nothrow(rootdir),
                \ 'out_io' : 'file',
                \ 'out_name' : out_path,
                \ })
    else
        call s:error('Could not find msbuild.xml.')
    endif
endfunction

function s:close_handler_msbuild_build(out_path, rootdir, cmd, channel)
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
                let dict['filename'] = fullpath
            endif
        endif
        if has_key(dict, 'filename')
            let dict['lnum'] = m[2]
            let dict['col'] = m[3]
            if (m[4] == 'error')
                let dict['type'] = 'E'
                let errcnt += 1
            elseif (m[4] == 'warning')
                let dict['type'] = 'W'
            endif
            let dict['text'] = m[5]
        else
            let dict['text'] = line
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

