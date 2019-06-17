
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

let g:loaded_rbtnn = 1

let s:vcvars32 = expand(printf('%s\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars32.bat', getenv('ProgramFiles(x86)')))
let s:sdkinclude = '%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A\Include'
let s:vimdev_src = expand('~/Desktop/vim/src')

function! s:vimdev(cmd) abort
    let bnr = term_start(['cmd', '/K', s:vcvars32], {
        \   'cwd' : s:vimdev_src,
        \ })
    call term_sendkeys(bnr, printf("%s\<cr>", a:cmd))
    call term_sendkeys(bnr, printf("%s\<cr>", 'exit'))
endfunction

function! s:setup() abort
    command! -nargs=0        ReadingVimrc     :call readingvimrc#open_list()
    command! -nargs=1        MSBuildNew       :call msbuild#new(<q-args>)
    command! -nargs=?        MSBuildBuild     :call msbuild#build(<q-args>)
    command! -nargs=?        MSBuildRun       :call msbuild#run(<q-args>)
    command! -nargs=1        HttpJsonPP       :call scratch#new(prettyprint#exec(json_decode(http#get_content(<q-args>)))) | setlocal filetype=json
    if has('win32')
        "if has('gui_running')
        "    command! -bar -nargs=0 FullScreenToggle   :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)
        "    command!      -nargs=1 SetAlpha           :call libcallnr('vimtweak.dll', 'SetAlpha', <args>)
        "endif
        if isdirectory(s:vimdev_src)
            command! -nargs=0 VimDevCmdIdxs   :call <SID>vimdev('nmake -f Make_mvc.mak cmdidxs')
            command! -nargs=0 VimDevClean     :call <SID>vimdev('nmake -f Make_mvc.mak clean')
            command! -nargs=0 VimDevBuild     :call <SID>vimdev(printf('nmake -f Make_mvc.mak SDK_INCLUDE_DIR="%s" VIMDLL=yes', s:sdkinclude))
            command! -nargs=0 VimDevRunGvim   :execute printf('!start "%s/gvim.exe"', s:vimdev_src)
            command! -nargs=0 VimDevRunVim    :execute printf('!start "%s/vim.exe"', s:vimdev_src)
            command! -nargs=0 VimDevChangeDir :execute printf('cd "%s"', s:vimdev_src)
        endif
    endif
endfunction

command! -nargs=0        SetupCommands       :call <SID>setup()

