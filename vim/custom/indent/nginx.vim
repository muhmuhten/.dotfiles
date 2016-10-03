if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setl inde= cin cink-=0#
let b:undo_indent = "setl inde< cin< cink<"
