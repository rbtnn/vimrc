#!/bin/bash
CUR_DIR=$(cd $(dirname $0);pwd)
PLUGIN_DIR=${CUR_DIR}/.vim/pack/my/start

if [ ! -d ${PLUGIN_DIR} ]; then
	mkdir -p ${PLUGIN_DIR}
fi

function plug() {
	if [ -d ${PLUGIN_DIR}/$2 ]; then
		pushd ${PLUGIN_DIR}/$2
		git pull
		popd
	else
		pushd ${PLUGIN_DIR}
		git clone --depth 1 https://github.com/$1/$2.git
		popd
	fi
}

plug cormacrelf  vim-colors-github
plug kana        vim-operator-replace
plug kana        vim-operator-user
plug lambdalisue fern.vim
plug rbtnn       vim-diffy
plug rbtnn       vim-gloaded
plug rbtnn       vim-grizzly
plug rbtnn       vim-vimscript_tagfunc
plug thinca      vim-qfreplace
plug tyru        caw.vim
plug tyru        restart.vim

