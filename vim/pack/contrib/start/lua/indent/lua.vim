" Vim indent file
" Language:	Lua script
" Maintainer:	Marcus Aurelius Farias <marcus.cf 'at' bol.com.br>
" First Author:	Max Ischenko <mfi 'at' ukr.net>
" Last Change:	2016 Jan 10

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal indentexpr=GetLuaIndent(v:lnum)

" To make Vim call GetLuaIndent() when it finds '\s*end' or '\s*until'
" on the current line ('else' is default and includes 'elseif').
setlocal indentkeys+=},),=end,=else,=until

let b:undo_indent = "setlocal indentexpr< indentkeys<"

function! IsLuaCode(lnum, ind)
	let ty = synIDattr(synID(a:lnum, a:ind, 0), "name")
	return ty != "" && ty != "luaComment" && ty[0:8] != "luaString"
endfunction

function! GetLuaIndent(lnum)
	" Find a non-blank line above the current line.
	let prevlnum = prevnonblank(a:lnum - 1)
	" Anything goes if the previous line started inside a comment
	if synIDattr(synID(prevlnum, 1, 0), "name") == "luaComment"
		return -1
	end

	" Nothing should be increasing the indent for the first line.
	if prevlnum == 0
		return 0
	endif

	" Add a 'shiftwidth' after lines that start a block:
	" 'function', 'if', 'for', 'while', 'repeat', 'else', 'elseif', '{'
	let indpat = '[({]\|\<\%(function\|do\|then\|else\|repeat\)\>'
	let undpat = '[})]\|\<\%(end\|else\%(if\)\?\|until\)\>'
	let dent = 0

	" Indentation changes based on previous line
	let line = getline(prevlnum)

	let lastix = 0
	while lastix >= 0
		let lastix = matchend(line, indpat, lastix)
		" Add 'shiftwidth' if what we found previously is not in a comment.
		if IsLuaCode(prevlnum, lastix)
			let dent = dent + 1
		endif
	endwhile

	" When ending tokens are *not* the first thing on the line, defer the effect
	" on indentation to the next line.
	let lastix = matchend(line, '^\%([[:space:]]*\%(' . undpat . '\)\)*')
	while lastix >= 0
		let lastix = matchend(line, undpat, lastix)
		if IsLuaCode(prevlnum, lastix)
			let dent = dent - 1
		endif
	endwhile

	" Indentation changes based on current line
	let line = getline(a:lnum)

	" Count all instances of the unindent patterns.
	let lastix = 0
	while lastix >= 0
		let lastix = matchend(line, undpat, lastix)
		if IsLuaCode(a:lnum, lastix)
			let dent = dent - 1
		endif
	endwhile

	" Count back the instances *after* the beginning of the line, which were
	" because they're getting counted next line.
	let lastix = matchend(line, '^\%([[:space:]]*\%(' . undpat . '\)\)*')
	while lastix >= 0
		let lastix = matchend(line, undpat, lastix)
		if IsLuaCode(a:lnum, lastix)
			let dent = dent + 1
		endif
	endwhile

	return indent(prevlnum) + shiftwidth()*dent
endfunction
