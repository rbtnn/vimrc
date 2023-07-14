
let $MYVIMRC = resolve($MYVIMRC)
let $VIMRC_VIM = expand(expand('<sfile>:h') .. '/vim')

source $VIMRC_VIM/settings/options.vim
source $VIMRC_VIM/settings/autocmds.vim

if has('vim_starting')
    set packpath=$VIMRC_VIM/local,$VIMRC_VIM/github
    set runtimepath=$VIMRUNTIME

    if has('win32') && has('gui_running')
        " https://github.com/yuru7/udev-gothic
        set guifont=UDEV_Gothic:h12:cSHIFTJIS:qDRAFT
        set linespace=0
    endif

    silent! source ~/.vimrc.local

    filetype plugin indent on
    syntax enable
    packloadall
endif

source $VIMRC_VIM/settings/plugins.vim
source $VIMRC_VIM/settings/mappings.vim
source $VIMRC_VIM/settings/tabsidebar.vim
source $VIMRC_VIM/settings/vcvarsallterminal.vim
