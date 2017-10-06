setl cin cino+=:0

let s:undo = exists("b:undo_indent") ? b:undo_indent . "|" : ""
let b:undo_indent = s:undo . "setl cin< cino<"
