let s:cmt_chars = {
            \ "python" : "#",
            \ "vim" : "\"",
            \ "c" : "//",
            \ "cpp" : "//",
            \ "java" : "//",
            \ "lua" : "--",
            \ "sh" : "#",
            \ "matlab": "%",
            \ "make": "#",
            \ "rust": "//"
            \ }


function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction


function! IsCommentedWithSpace(line) abort
    let line = Strip(a:line)
    if line == ""
        return 0
    endif
    return split(a:line)[0] == GetComment()
endfunction


function! IsCommentedWithoutSpace(line) abort
    let comment = GetComment()
    let comment_length = strlen(comment)
    let line = Strip(a:line)
    return line[:comment_length - 1] == comment
endfunction


function! IsCommented(line) abort
    return IsCommentedWithSpace(a:line) || IsCommentedWithoutSpace(a:line)
endfunction


function! IsBlankLine(line) abort
    return len(split(a:line)) == 0
endfunction


function! GetComment() abort
    return get(s:cmt_chars, &filetype)
endfunction


function! Comment() abort
    let comment = GetComment()
    let right_presses = repeat("l", len(comment) + 1)
    execute "normal! mz_i".comment." \<Esc>`z".right_presses
endfunction


function! GetWhitespacesAfterComment(line) abort
    let comment = GetComment()
    let start_idx = stridx(a:line, comment) + len(comment)
    let idx = start_idx
    while idx < len(a:line) && a:line[idx] == " "
        let idx += 1
    endwhile
    return idx - start_idx
endfunction


function! Uncomment(line) abort
    let comment = GetComment()
    let offset = 0
    if IsCommentedWithSpace(a:line)
        let offset = GetWhitespacesAfterComment(a:line)
    endif
    let left_presses = repeat("h", min([offset + len(comment), len(a:line) - col('.')]))
    let del_presses = repeat("x", len(comment) + offset)
    execute "normal! mz_".del_presses." \<Esc>`z".left_presses
endfunction


function! GetUncommentedLineNumbers(lines, offset) abort 
    let comment = GetComment()
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
            call Uncomment(line)
            execute "normal! j"
        endfor
    endif
endfunction


function! autocomment#comment() abort
    let line = getline('.')
    if IsBlankLine(line)
        return
    endif

    if !IsCommented(line)
        call Comment()
    else
        call Uncomment(line)
    endif
endfunction

