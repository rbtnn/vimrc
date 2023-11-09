
if exists("b:current_syntax")
  finish
endif

syntax match  GitStatusInfo1  '^.. '
syntax match  GitStatusInfo2  '^?? '

highlight default link GitStatusInfo1      Constant
highlight default link GitStatusInfo2      Identifier
