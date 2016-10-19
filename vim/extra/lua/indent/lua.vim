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

function! InLuaComment(lnum, ind)
	if a:ind < 0
		return 1
	end

	return synIDattr(synID(a:lnum, a:ind, 0), "name") == "luaComment"
endfunction

function! GetLuaIndent(lnum)
	" Find a non-blank line above the current line.
	let prevlnum = prevnonblank(a:lnum - 1)

	" Nothing should be increasing the indent for the first line.
	if prevlnum == 0
		return 0
	endif

	" Add a 'shiftwidth' after lines that start a block:
	" 'function', 'if', 'for', 'while', 'repeat', 'else', 'elseif', '{'
	let ind = indent(prevlnum)
	let indpat = '[({]\|\<\%(function\|do\|then\|else\|repeat\)\>'
	let undpat = '[})]\|\<\%(end\|else\%(if\)\?\|until\)\>'

	" Indentation changes based on previous line
	let line = getline(prevlnum)

	let lastind = 0
	while lastind >= 0
		let lastind = matchend(line, indpat, lastind)
		" Add 'shiftwidth' if what we found previously is not in a comment.
		if !InLuaComment(prevlnum, lastind)
			let ind = ind + shiftwidth()
		endif
	endwhile

	" When ending tokens are *not* the first thing on the line, defer the effect
	" on indentation to the next line.
	let lastind = matchend(line, '^[[:space:]]*\%(' . undpat . '\)*')
	while lastind >= 0
		let lastind = matchend(line, undpat, lastind)
		if !InLuaComment(prevlnum, lastind)
			let ind = ind - shiftwidth()
		endif
	endwhile

	" Indentation changes based on current line
	let line = getline(a:lnum)

	" Count all instances of the unindent patterns.
	let lastind = 0
	while lastind >= 0
		let lastind = matchend(line, undpat, lastind)
		if !InLuaComment(a:lnum, lastind)
			let ind = ind - shiftwidth()
		endif
	endwhile

	" Count back the instances *after* the beginning of the line, which were
	" because they're getting counted next line.
	let lastind = matchend(line, '^[[:space:]]*\%(' . undpat . '\)*')
	while lastind >= 0
		let lastind = matchend(line, undpat, lastind)
		if !InLuaComment(a:lnum, lastind)
			let ind = ind + shiftwidth()
		endif
	endwhile

	if ind < 0
		return 0
	end

	return ind
endfunction
