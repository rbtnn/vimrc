
if exists("b:current_syntax")
  finish
endif

syntax match           fDir   '.*/$'
highlight default link fDir   Directory
