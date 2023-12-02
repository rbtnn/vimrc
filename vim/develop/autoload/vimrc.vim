
function! vimrc#init() abort
    let g:git_lsfiles_ignore_exts = get(g:, 'git_lsfiles_ignore_exts', [
        \ 'exe', 'o', 'obj', 'xls', 'doc', 'xlsx', 'docx', 'dll', 'png', 'jpg', 'ico', 'pdf', 'mp3', 'zip',
        \ 'ttf', 'gif', 'otf', 'wav', 'm4a', 'ai', 'tgz'
        \ ])
    let g:git_lsfiles_ignore_patterns = get(g:, 'git_lsfiles_ignore_patterns', [])
    let g:git_lsfiles_maximum = get(g:, 'git_lsfiles_maximum', 100)
    let g:git_enabled_qficonv = get(g:, 'git_enabled_qficonv', v:false)
    let g:git_enabled_match_query = get(g:, 'git_enabled_match_query', v:true)
    let g:ripgrep_ignore_patterns = get(g:, 'rggrep_ignore_patterns', [
        \ 'min.js$', 'min.js.map$',
        \ ])
endfunction
