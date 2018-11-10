
syntax region  gstatInfoDiff        start='|\s*\d\+'      end='$' contains=gstatDelimiter,gstatInsertion,gstatDeletion
syntax region  gstatInfoBin         start='|\s*Bin'       end='$' contains=gstatDelimiter
syntax region  gstatInfoUnmerged    start='|\s*Unmerged'  end='$' contains=gstatDelimiter
syntax match   gstatDelimiter  '|' contained
syntax match   gstatInsertion  '+' contained
syntax match   gstatDeletion   '-' contained

highlight! def link gstatInsertion       DiffAdd
highlight! def link gstatDeletion        DiffDelete
highlight! def link gstatDelimiter       NonText
highlight! def link gstatInfoBin         Error
highlight! def link gstatInfoUnmerged    Error
