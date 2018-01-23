" Vim indent file
" Language:	Lua script
" Maintainer:	Marcus Aurelius Farias <marcus.cf 'at' bol.com.br>
" First Author:	Max Ischenko <mfi 'at' ukr.net>
" Last Change:	2016 Jan 10

if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal indentexpr=GetLuaIndent(v:lnum)
setlocal indentkeys+=},),=do,=until,=then,=else,=end
let b:undo_indent = "setlocal indentexpr< indentkeys<"

function! s:is_code(lnum, ind)
	let ty = synIDattr(synID(a:lnum, a:ind, 0), "name")
	return ty != "luaComment" && ty != "luaString"
endfunction

function! s:words(lnum)
	let out = []
	let line = getline(a:lnum)
	let line = substitute(line, '\v"%([^"]|\\.)*"', '""', "g")
	let line = substitute(line, '\v--.*', "", "")
	let s1 = split(line, '\v<|>')
	for word in s1
		" 0 on match, -1 on non-words
		if match(word, '\v<') == -1
			call extend(out, split(word, '\v\s*'))
		else
			call add(out, word)
		endif
	endfor
	return out
endfunction

function! GetWords(lnum)
	return s:words(a:lnum)
endfunction

let s:prices = {
			\"(": 1,
			\")": -1,
			\"do": 0,
			\"else": 0,
			\"elseif": 0,
			\"end": -1,
			\"for": 1,
			\"function": 1,
			\"if": 1,
			\"repeat": 1,
			\"then": 0,
			\"until": -1,
			\"while": 1,
			\"{": 1,
			\"}": -1}

function! GetLuaIndent(lnum)
	if a:lnum <= 1
		return 0
	end

	if !s:is_code(a:lnum, 1)
		return -1
	end

	let debt = 0
	let seendos = []

	for word in s:words(a:lnum)
		if get(s:prices, word, 1) <= 0
			let debt -= 1
			if word == "do"
				call add(seendos, -1)
			endif
		endif
		if get(s:prices, word) >= 0
			break
		endif
	endfor

	let lnum = a:lnum
	"echo [lnum, debt]
	let done = 0
	while !done && lnum > 1
		let lnum = prevnonblank(lnum-1)
		if lnum <= 0
			let lnum = 1
			break
		endif

		for word in reverse(s:words(lnum))
			let price = get(s:prices, word, 2)
			if price == 2
				continue
			endif

			if word == "do"
				call add(seendos, debt)
			elseif word == "for" || word == "while"
				while len(seendos)
					if remove(seendos, -1) >= debt
						break
					endif

					let debt += 1
				endwhile
			endif
			"echo [word, debt, seendos]

			let debt += price
			if debt >= 0
				let done = 1
			endif
			"echo [lnum, debt, price, word]
		endfor
	endwhile

	"echo ["dos", seendos]
	if debt >= 0
		let done = 1
	endif

	"echo s:words(lnum)
	for word in s:words(lnum)
		if get(s:prices, word, 1) <= 0 && word != "do"
			let debt += 1
		endif
		if get(s:prices, word) >= 0
			break
		endif
	endfor

	let debt += len(seendos)

	"echo [lnum, indent(lnum), debt]
	return indent(lnum) + shiftwidth() * debt
endfunction
