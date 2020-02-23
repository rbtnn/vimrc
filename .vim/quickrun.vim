
scriptencoding utf-8

let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config['_'] = {
    \   'runner' : 'terminal',
    \   'runner/terminal/into' : 1,
    \ }
" let g:quickrun_config['_']['hook/output_encode/encoding'] = &encoding
" let g:quickrun_config['_']['hook/output_encode/encoding'] = &termencoding

