
" Can't use <S-space> at :terminal
" https://github.com/vim/vim/issues/6040
tnoremap <silent><S-space>           <space>

" Smart space on wildmenu
cnoremap <expr><space>             (wildmenumode() && (getcmdline() =~# '[\/]$')) ? '<space><bs>' : '<space>'

" Emacs key mappings
if has('win32') && (&shell =~# '\<cmd\.exe$')
    tnoremap <silent><C-p>           <up>
    tnoremap <silent><C-n>           <down>
    tnoremap <silent><C-b>           <left>
    tnoremap <silent><C-f>           <right>
    tnoremap <silent><C-e>           <end>
    tnoremap <silent><C-a>           <home>
    tnoremap <silent><C-u>           <esc>
endif

cnoremap         <C-b>        <left>
cnoremap         <C-f>        <right>
cnoremap         <C-e>        <end>
cnoremap         <C-a>        <home>

nnoremap <silent><C-n>    <Cmd>cnext     \| normal zz<cr>
nnoremap <silent><C-p>    <Cmd>cprevious \| normal zz<cr>

nnoremap <silent><C-j>         gt
nnoremap <silent><C-k>         gT
tnoremap <silent><C-j>    <C-w>gt
tnoremap <silent><C-k>    <C-w>gT