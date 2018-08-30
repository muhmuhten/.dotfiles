if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal indentexpr=JqIndent(v:lnum)
let b:undo_indent = "setlocal indentexpr< indentkeys<"

function! JqIndent(lnum)
	let lnum = prevnonblank(a:lnum-1)
	let line = getline(lnum)

	let dent = 0
	if match(line, '\v^\s*def\s+') != -1
		let dent += 1
	endif
	if line[-1:] == ';'
		let dent -= 1
	endif

	return indent(lnum) + dent * shiftwidth()
endfunction
