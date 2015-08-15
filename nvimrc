se nocp enc=utf-8 et sw=2 ts=2 lbr nu nuw=7 bs=2
se ls=2 stl=%F\ %y%r%h%w%m\ =%02B\ (%l,%v)[%L/%02p%%]
se swf dir=~/.vim/store inde=HangInd() 
se bk bdir=~/.vim/store bkc=yes,breakhardlink
au BufWritePre * let &bex = strftime('@%F-%T~')

sy on
filet plugin indent on
colo desert

au BufEnter *.ass se ft=ass
au BufEnter *.md  se ft=markdown
au BufEnter */coreos-install/user_data se ft=yaml
au BufEnter */nginx*.conf se ft=nginx
au BufEnter /etc/hosts se ts=16 noet
au BufEnter APKBUILD set filetype=sh
au BufEnter DefaultKeyBinding.dict se inde= cin

au FileType ass se nobomb nowrap
au FileType c,cpp,nginx se inde= cin
au FileType coffee,scss se inde=HangInd()
au FileType crontab se bkc=yes

au FileType conf if getline(1) =~ '^#!.*\<ash\>' | se ft=sh | en

no U <C-r>
no ZZ :up<CR>
no ZQ :q<CR>

exe pathogen#infect()

let g:SuperTabDefaultCompletionType = 'context'

function HangInd()
  let lnum = prevnonblank(v:lnum-1)

  if lnum <= 0
    return 0
  endif

  let indent = indent(lnum)
  let line = getline(lnum)

  while line =~ '\m{'
    let line = substitute(line, '\m{', '', '')
    let indent = indent + &sw
  endwhile

  while line =~ '\m}'
    let line = substitute(line, '\m}', '', '')
    let indent = indent - &sw
  endwhile

  return indent
endfunction
