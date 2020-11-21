" XXX this shouldn't really be this way but they're set up in autoload
let g:vimwiki_global_vars.autowriteall = 0
let g:vimwiki_global_vars.conceallevel = 0

call vimwiki#u#map_key('n', '<Esc>OM', '<Plug>VimwikiFollowLink')
call vimwiki#u#map_key('n', '<CR>', '<Plug>VimwikiTabnewLink')
call vimwiki#u#map_key('n', '<Esc>[3~', '<Plug>VimwikiGoBackLink')

function! vimwiki#base#system_open_link(url) abort
  try
    call system('/Applications/Firefox.app/Contents/MacOS/firefox -private-window '.shellescape(a:url).'&')
  catch
    echomsg 'Vimwiki Error: Default Vimwiki link handler was unable to open the HTML file!'
  endtry
endfunction
