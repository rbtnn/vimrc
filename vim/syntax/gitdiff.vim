if exists("b:current_syntax")
  finish
endif

syntax match   gitDiffCmnt     '^#.*$'
syntax match   gitDiffLine     '^\s*+\d\+\s\+-\d\+\s.*$' contains=gitDiffAdded,gitDiffRemoved
syntax match   gitDiffAdded    '+\d\+\s'                 contained
syntax match   gitDiffRemoved  '-\d\+\s'                 contained
highlight default link gitDiffCmnt   Comment
highlight default link gitDiffLine   Normal
if hlexists('diffAdded')
	highlight default link gitDiffAdded   diffAdded
elseif hlexists('DiffAdd')
	highlight default link gitDiffAdded   DiffAdd
endif
if hlexists('diffRemoved')
	highlight default link gitDiffRemoved   diffRemoved
elseif hlexists('DiffDelete')
	highlight default link gitDiffRemoved   DiffDelete
endif
