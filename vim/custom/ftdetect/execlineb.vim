fu! s:check_execlineb()
	if getline(1) =~ '^#!.*\<execlineb\>'
		se ft=execlineb
	en
endf

au BufEnter * call s:check_execlineb()
