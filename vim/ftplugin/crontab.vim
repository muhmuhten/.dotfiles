setl bkc=yes

let s:undo = exists("b:undo_ftplugin") ? b:undo_ftplugin . "|" : ""
let b:undo_ftplugin = s:undo . "setl bkc<"
