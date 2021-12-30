let s:cmt_chars = {
            \ "python" : "#",
            \ "vim" : "\"",
            \ "c" : "//",
            \ "cpp" : "//",
            \ "java" : "//",
            \ "lua" : "--",
            \ "sh" : "#",
            \ "matlab": "%"
            \ }


function! IsCommented(line) abort
    return split(a:line)[0] == get(s:cmt_chars, &filetype)
endfunction


function! IsBlankLine(line) abort
    return len(split(a:line)) == 0
endfunction


function! Comment() abort
    let comment = get(s:cmt_chars, &filetype)
    let right_presses = repeat("l", len(comment)+1)
    execute "normal! mz^i".comment." \<Esc>`z".right_presses
endfunction


function! Uncomment() abort
    let comment = get(s:cmt_chars, &filetype)
    let left_presses = repeat("h", len(comment)+1)
    let del_presses = repeat("x", len(comment)+1)
    execute "normal! mz^".del_presses." \<Esc>`z".left_presses
endfunction


function! GetUncommentedLineNumbers(lines, offset) abort 
    let comment = get(s:cmt_chars, &filetype)
    let list = []

    let idx = 0
    while idx < len(a:lines)
        let line = a:lines[idx]
        if !IsBlankLine(line) && !IsCommented(line)  
            call add(list, idx + a:offset)
        endif
        let idx += 1
    endwhile

    return list
endfunction


function! autocomment#comment_range(start, end, range) abort
    if a:range == 0
        call autocomment#comment()
        return
    endif

    let lines = getline(a:start, a:end)
    let uncommented_line_nums = GetUncommentedLineNumbers(lines, a:start)

    " Get in position to start comment/uncomment process
    execute "normal! ".a:start."G"
    " If there are any lines uncommented in the range, comment them
    if len(uncommented_line_nums) > 0
        for line_num in uncommented_line_nums
            execute "normal! ".line_num."G"
            call Comment()
        endfor
    else
        for line in lines
            call Uncomment()
            execute "normal! j"
        endfor
    endif
endfunction


function! autocomment#comment() abort
    let line = getline('.')
    if !IsBlankLine(line) && !IsCommented(line)
        call Comment()
    else
        call Uncomment()
    endif
endfunction


