
if exists(':scriptversion')
    scriptversion 3
else
    finish
endif

let g:loaded_rbtnn = 1

function! s:setup() abort
    command! -nargs=0        ReadingVimrc     :call readingvimrc#open_list()
    command! -nargs=1        MSBuildNew       :call msbuild#new(<q-args>)
    command! -nargs=?        MSBuildBuild     :call msbuild#build(<q-args>)
    command! -nargs=?        MSBuildRun       :call msbuild#run(<q-args>)
    if has('win32')
        if has('gui_running')
            command! -bar -nargs=0 FullScreenToggle   :call libcallnr('gvimfullscreen.dll', 'ToggleFullScreen', 0)
            command!      -nargs=1 SetAlpha           :call libcallnr('vimtweak.dll', 'SetAlpha', <args>)
        endif
    endif
endfunction

command! -nargs=0        SetupCommands       :call <SID>setup()

