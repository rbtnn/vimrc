
if exists("b:current_syntax")
  finish
endif

syntax match   diffyAdditions      '+\d\+'
syntax match   diffyDeletions      '-\d\+'

