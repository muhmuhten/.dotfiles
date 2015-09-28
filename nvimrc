se et sw=2 ts=2 lbr nu nuw=7
se ls=2 stl=%F\ %y%r%h%w%m\ =%02B\ (%l,%v)[%L/%02p%%]
se swf dir=~/.vim/store bk bdir=~/.vim/store bkc=yes,breakhardlink
au BufWritePre * let &bex = strftime('@%F-%T~')

no U <C-r>

sy on
filet plugin indent on
colo desert

au BufEnter *.ass se ft=ass
au BufEnter *.md  se ft=markdown
au BufEnter */ng*.conf se ft=nginx
au BufEnter */*_vars/* se ft=yaml


au BufEnter /etc/hosts se ts=16 noet
au BufEnter APKBUILD se ft=sh

au FileType ass se nobomb nowrap
au FileType c,cpp,nginx se cin
au FileType crontab se bkc=yes

au FileType conf if getline(1) =~ '^#!.*\<ash\>' | se ft=sh | en

exe pathogen#infect()

let g:SuperTabDefaultCompletionType = 'context'
