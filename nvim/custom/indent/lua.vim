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
setlocal indentkeys+=0=end,0=until

setlocal autoindent

" Only define the function once.
if exists("*GetLuaIndent")
  finish
endif

function! InLuaComment(lnum, ind)
  if a:ind < 0
    return 1
  end

  return synIDattr(synID(a:lnum, a:ind, 0), "name") == "luaComment"
endfunction

function! GetLuaIndent(lnum)
  " Find a non-blank line above the current line.
  let prevlnum = prevnonblank(a:lnum - 1)

  " Hit the start of the file, use zero indent.
  if prevlnum == 0
    return 0
  endif

  " Add a 'shiftwidth' after lines that start a block:
  " 'function', 'if', 'for', 'while', 'repeat', 'else', 'elseif', '{'
  let ind = indent(prevlnum)

  " Indentation changes based on previous line
  let line = getline(prevlnum)

  let indpat = '[({]\|\<\%(do\|then\|repeat\)\>'
  let lastind = 0
  while lastind >= 0
    let lastind = matchend(line, indpat, lastind)
    " Add 'shiftwidth' if what we found previously is not in a comment.
    if !InLuaComment(prevlnum, lastind)
      let ind = ind + &shiftwidth
    endif
  endwhile

  let lastind = matchend(line, '^[[:space:]]*[^})[:space:]]')
  while lastind >= 0
    let lastind = matchend(line, '[})]', lastind)
    if !InLuaComment(prevlnum, lastind)
      let ind = ind - &shiftwidth
    endif
  endwhile

  " Indentation changes based on current line
  let line = getline(a:lnum)

  let lastind = matchend(line, '^[[:space:]]*[^})[:space:]]')
  while lastind >= 0
    let lastind = matchend(line, '[})]', lastind)
    if !InLuaComment(prevlnum, lastind)
      let ind = ind + &shiftwidth
    endif
  endwhile

  let undpat = '[})]\|\<\%(end\|else\%(if\)\?\|until\)\>'
  let lastind = 0
  while lastind >= 0
    let lastind = matchend(line, undpat, lastind)
    if !InLuaComment(a:lnum, lastind)
      let ind = ind - &shiftwidth
    endif
  endwhile

  return ind
endfunction
