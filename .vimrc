scriptencoding utf-8
let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')
let $VIMRC_PKGSYNC_DIR = expand('$VIMRC_VIM/github/pack/rbtnn/start/vim-pkgsync')

source $VIMRC_VIM/settings/options.vim
source $VIMRC_VIM/settings/autocmds.vim

function! s:exists_font(fname) abort
    return filereadable(expand('$USERPROFILE/AppData/Local/Microsoft/Windows/Fonts/' .. a:fname))
        \ || filereadable(expand('C:/Windows/Fonts/' .. a:fname))
endfunction

function! s:source_plugin_settings(dirname) abort
    if isdirectory($VIMRC_PKGSYNC_DIR)
        for s:setting in sort(split(globpath($VIMRC_VIM, printf('settings/plugins/%s/*', a:dirname)), '\n'))
            for s:plugin in sort(split(globpath($VIMRC_VIM, 'github/pack/*/*/*'), '\n'))
                let s:x = split(s:setting, '[\/]')[-1]
                let s:y = split(s:plugin, '[\/]')[-1]
                if (tolower(s:x) == tolower(s:y .. '.vim')) || (tolower(s:x) == tolower(s:y))
                    execute 'source' s:setting
                endif
            endfor
        endfor
    endif
endfunction

if has('vim_starting')
    set packpath=$VIMRC_VIM/github
    set runtimepath=$VIMRC_VIM/develop,$VIMRUNTIME

    if has('win32') && has('gui_running')
        set linespace=0
        if s:exists_font('UDEVGothic-Regular.ttf')
            " https://github.com/yuru7/udev-gothic
            set guifont=UDEV_Gothic:h16:cSHIFTJIS:qDRAFT
        elseif s:exists_font('Cica-Regular.ttf')
            " https://github.com/miiton/Cica
            set guifont=Cica:h16:cSHIFTJIS:qDRAFT
        else
            set guifont=ＭＳ_ゴシック:h18:cSHIFTJIS:qDRAFT
        endif
    endif

    silent! source ~/.vimrc.local

    call s:source_plugin_settings('before')

    filetype plugin indent on
    syntax enable
    packloadall

    call s:source_plugin_settings('after')

    if !isdirectory($VIMRC_PKGSYNC_DIR)
        function! PkgSyncSetup() abort
            let path = expand('$VIMRC_VIM/github/pack/rbtnn/start/')
            silent! call mkdir(path, 'p')
            call term_start(['git', 'clone', '--depth', '1', 'https://github.com/rbtnn/vim-pkgsync.git'], {
                \ 'cwd': path,
                \ })
        endfunction
        autocmd vimrc-plugins VimEnter *
            \ :if !exists(':PkgSync')
            \ |  execute 'command! -nargs=0 PkgSyncSetup :call PkgSyncSetup()'
            \ |endif
    endif
endif

source $VIMRC_VIM/settings/mappings.vim
source $VIMRC_VIM/settings/tabsidebar.vim
source $VIMRC_VIM/settings/colorscheme.vim
