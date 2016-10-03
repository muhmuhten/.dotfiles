let g:html_indent_script1 = 'inc'
let g:html_indent_style1 = 'inc'

setl ts=2

let s:undo = exists("b:undo_indent") ? b:undo_indent . "|" : ""
let b:undo_indent = s:undo . "setl ts<"
