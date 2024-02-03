
if exists("b:current_syntax")
  finish
endif

syntax match  GitDiffNumstatAdd     '^\d\+'
syntax match  GitDiffNumstatDelete  '\t\d\+\t'

highlight default link GitDiffNumstatAdd       DiffAdd
highlight default link GitDiffNumstatDelete    DiffDelete
