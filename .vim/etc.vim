
scriptencoding utf-8

augroup vimrc_visualbasic
    autocmd!
    autocmd FileType frm,bas,cls :setfiletype vb
    autocmd Syntax            vb :syntax keyword vbKeyword ReadOnly Protected Imports Module Try Catch Overrides Shared Class Finally Using Continue Of
augroup END

augroup vimrc_ukefile
    autocmd!
    autocmd BufEnter       *.uke :setfiletype uke
augroup END

