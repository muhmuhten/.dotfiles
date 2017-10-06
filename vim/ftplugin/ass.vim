setl nobomb nowrap

let s:undo = exists("b:undo_ftplugin") ? b:undo_ftplugin . "|" : ""
let b:undo_ftplugin = s:undo . "setl bomb< wrap<"
