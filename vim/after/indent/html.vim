setl inde=FixedHtmlIndent()
func! FixedHtmlIndent()
	let indent = HtmlIndent()
	let b:hi_lasttick = b:changedtick - 1
	return indent
endfunc
