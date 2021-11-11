nnoremap <Plug>AutoComment :call autocomment#comment()<CR>
nmap <silent><leader>/ <Plug>AutoComment

command! -range AutoCommentRange call autocomment#comment_range(<line1>, <line2>, <range>)
vnoremap <silent><leader>/ :AutoCommentRange<CR>gv


