let $VIMRC_ROOT = expand('<sfile>:h')
let $VIMRC_VIM = expand('$VIMRC_ROOT/vim')
call system(printf('curl -o "%s" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', expand('$VIMRC_VIM/autoload/plug.vim')))
set runtimepath=$VIMRUNTIME,$VIMRC_VIM
filetype indent plugin on
PlugUpdate
