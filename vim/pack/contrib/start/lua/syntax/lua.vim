" Vim syntax file
" Language:	Lua 5.1/5.2/JIT abomination
" Maintainer:	Marcus Aurelius Farias <masserahguard-lua 'at' yahoo com>
" First Author:	Carlos Augusto Teixeira Mendes <cmendes 'at' inf puc-rio br>
" Last Change:	2012 Aug 12

if exists("b:current_syntax")
	finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match

" syncing method
syn sync minlines=100

" Comments
syn keyword luaTodo contained TODO FIXME XXX
syn match luaComment "\%^#!.*"
syn match luaComment "--.*$" contains=luaTodo,@Spell
syn region luaComment matchgroup=luaComment start="--\[\z(=*\)\[" end="\]\z1\]" contains=luaTodo,@Spell

" catch errors caused by wrong parenthesis and wrong curly brackets or
" keywords placed outside their respective blocks
syn region luaParen transparent start='(' end=')' contains=ALLBUT,luaParenError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement
syn region luaTableBlock transparent matchgroup=luaTable start="{" end="}" contains=ALLBUT,luaBraceError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement

syn match luaParenError ")"
syn match luaBraceError "}"
" strange bracing here is to avoid a vimscript indent bug
syn match luaError "\v<%(e(nd|lse|lseif)|then|until|in)>"

" function ... end
syn region luaFunctionBlock transparent matchgroup=luaFunction start="\v<function>" end="\v<end>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" if ... then
syn region luaIfThen transparent matchgroup=luaCond start="\v<if>" end="\v<then>"me=e-4 contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaIn nextgroup=luaThenEnd skipwhite skipempty

" then ... end
syn region luaThenEnd contained transparent matchgroup=luaCond start="\v<then>" end="\v<end>" contains=ALLBUT,luaTodo,luaSpecial,luaThenEnd,luaIn

" elseif ... then
syn region luaElseifThen contained transparent matchgroup=luaCond start="\v<elseif>" end="\v<then>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" else
syn keyword luaElse contained else

" do ... end
syn region luaBlock transparent matchgroup=luaRepeat start="\v<do>" end="\v<end>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" repeat ... until
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\v<repeat>" end="\v<until>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" while ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\v<while>" end="\v<do>"me=e-2 contains=ALLBUT,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaIn nextgroup=luaBlock skipwhite skipempty

" for ... do and for ... in ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\v<for>" end="\v<do>"me=e-2 contains=ALLBUT,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd nextgroup=luaBlock skipwhite skipempty
syn keyword luaIn contained in

" other keywords
syn keyword luaStatement return local break
syn keyword luaStatement goto
syn match luaLabel "::\I\i*::"
syn keyword luaOperator and or not
syn keyword luaConstant nil
syn keyword luaConstant true false

" Strings
syn match luaSpecial contained #\\[\\abfnrtvz'"]\|\\x[[:xdigit:]]\{2}\|\\[[:digit:]]\{,3}#
syn region luaString2 matchgroup=luaString start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
syn region luaString start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=luaSpecial,@Spell
syn region luaString start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,@Spell

" integer number
syn match luaNumber "\v<\d+%([uU]?[lL][lL])?>"
" floating point number, with dot, optional exponent
syn match luaNumber "\v<\d+\.\d*%([eE][-+]?\d+)?>"
" floating point number, starting with a dot, optional exponent
syn match luaNumber "\v\.\d+%([eE][-+]?\d+)?>"
" floating point number, without dot, with exponent
syn match luaNumber "\v<\d+[eE][-+]?\d+>"

" binary integer number
syn match luaNumber "\v<0[bB][01]+%([uU]?[lL][lL])?>"
" hex integer number
syn match luaNumber "\v<0[xX]\x+%([uU]?[lL][lL])?>"
" hex numbers
syn match luaNumber "\v<0[xX]%(\x|\.)+%([pP][-+]?\d+)?>"

syn keyword luaFunc assert collectgarbage dofile error next
syn keyword luaFunc print rawget rawset tonumber tostring type _VERSION
syn keyword luaFunc getmetatable setmetatable ipairs pairs pcall xpcall
syn keyword luaFunc _G load loadfile rawequal require select
syn match luaFunc "\v<%(package|bit|bit32|coroutine|math|string|table|io|os|debug|ffi|jit)\.\I\i*>"
syn keyword luaFunc getfenv setfenv loadstring module unpack
syn keyword luaFunc _ENV rawlen

" Define the default highlighting.
hi def link luaStatement    Statement
hi def link luaRepeat       Repeat
hi def link luaFor          Repeat
hi def link luaString       String
hi def link luaString2      String
hi def link luaNumber       Number
hi def link luaOperator     Operator
hi def link luaIn           Operator
hi def link luaConstant     Constant
hi def link luaCond         Conditional
hi def link luaElse         Conditional
hi def link luaFunction     Function
hi def link luaComment      Comment
hi def link luaTodo         Todo
hi def link luaTable        Structure
hi def link luaError        Error
hi def link luaParenError   Error
hi def link luaBraceError   Error
hi def link luaSpecial      SpecialChar
hi def link luaFunc         Identifier
hi def link luaLabel        Label

let b:current_syntax = "lua"

let &cpo = s:cpo_save
unlet s:cpo_save
