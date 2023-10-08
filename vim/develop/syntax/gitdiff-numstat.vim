
if exists("b:current_syntax")
  finish
endif

runtime syntax/diff.vim

syntax match  GitDiffNumStatRemoved  '\t\d\+\t'           contained
syntax match  GitDiffNumStatAdded    '^\d\+'              contained
syntax match  GitDiffNumStatLine     '^\d\+\t\d\+\t.\+$'  contains=GitDiffNumStatAdded,GitDiffNumStatRemoved

if hlexists('diffAdded')
  highlight default link GitDiffNumStatAdded      diffAdded
else
  highlight default link GitDiffNumStatAdded      DiffAdd
endif
if hlexists('diffRemoved')
  highlight default link GitDiffNumStatRemoved    diffRemoved
else
  highlight default link GitDiffNumStatRemoved    DiffDelete
endif
