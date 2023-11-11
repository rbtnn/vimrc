
function! git#config#init() abort
    let g:git_lsfiles_ignore_exts = get(g:, 'git_lsfiles_ignore_exts', [
        \ 'exe', 'o', 'obj', 'xls', 'doc', 'xlsx', 'docx', 'dll', 'png', 'jpg', 'ico', 'pdf', 'mp3', 'zip',
        \ 'ttf', 'gif', 'otf', 'wav', 'm4a', 'ai', 'tgz'
        \ ])
    let g:git_lsfiles_ignore_patterns = get(g:, 'git_lsfiles_ignore_patterns', [])
    let g:git_lsfiles_maximum = get(g:, 'git_lsfiles_maximum', 100)
    let g:git_enabled_qficonv = get(g:, 'git_enabled_qficonv', v:false)
endfunction