
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

function! prettyprint#exec(obj, depth = 0, prefix = '') abort
    let s = []
    let indent = repeat('  ', a:depth)
    if type(a:obj) == v:t_list
        let s += [indent .. a:prefix .. '[']
        for x in a:obj
            let s += prettyprint#exec(x, a:depth + 1)
        endfor
        if !empty(a:obj)
            let s[-1] = s[-1][:-2]
        endif
        let s += [indent .. '],']
    elseif type(a:obj) == v:t_dict
        let s += [indent .. a:prefix .. '{']
        for key in keys(a:obj)
            let s += prettyprint#exec(a:obj[key], a:depth + 1, ('"' .. escape(key, '"\') .. '" : '))
        endfor
        if !empty(a:obj)
            let s[-1] = s[-1][:-2]
        endif
        let s += [indent .. '},']
    elseif type(a:obj) == v:t_bool
        let s += [indent .. a:prefix .. (a:obj ? 'true' : 'false') .. ',']
    elseif type(a:obj) == v:t_none
        let s += [indent .. a:prefix .. 'null' .. ',']
    elseif type(a:obj) == v:t_string
        let s += [indent .. a:prefix .. '"' .. escape(a:obj, '"\') .. '",']
    else
        let s += [indent .. a:prefix .. string(a:obj) .. ',']
    endif
    return s
endfunction

