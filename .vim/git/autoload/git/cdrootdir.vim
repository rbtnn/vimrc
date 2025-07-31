
function! git#cdrootdir#exec() abort
  let rootdir = git#get_rootdir()
  if !empty(rootdir)
    if !empty(chdir(rootdir))
      call git#echo_message('Changed to git rootdir:')
      verbose pwd
      return
    endif
  endif
  call git#echo_error('Could not find a git rootdir!')
endfunction
