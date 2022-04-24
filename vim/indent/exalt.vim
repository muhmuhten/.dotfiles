 setl cin et ts=4

let s:undo = exists("b:undo_indent") ? b:undo_indent . "|" : ""
let b:undo_indent = s:undo . "setl cin< et< ts<"
