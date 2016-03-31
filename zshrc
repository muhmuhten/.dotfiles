setopt auto_pushd chase_links extended_glob interactive_comments
setopt magic_equal_subst multios rc_quotes rm_star_silent
setopt hist_ignore_dups hist_ignore_space hist_reduce_blanks
setopt share_history extended_history

if [ ! ${HISTFILE+1} ]; then
  HISTFILE=~/.zsh_history
  : >> "$HISTFILE"
  HISTSIZE=$((`wc -l < "$HISTFILE"`))
fi
zshaddhistory() ((HISTSIZE = SAVEHIST = HISTCMD))

precmd() {
  set -- "$?" "`print -P %M`" "$@"
  set -- "$1" "${2%.local*}" "${@:3}"
  print -P "%B%F{yellow}(%n@$2) %F{blue}[%D %*] %F{green}[%!] %F{magenta}($1) %F{cyan}(%~)%f"

  case $TERM in
    screen) print -Pn "\ek%~\e\\" ;;
    xterm*) print -Pn "\e]1;%n@%m:%~\a" ;;
  esac
}
PS1='%B%#%b '
PS2=$PS1

export HOME=$HOME:A
cd . # chase links

export CLICOLOR=1
export DOCKER_HOST=${DOCKER_HOST-unix:///tmp/docker.sock}
export GEM_HOME=~/Sandbox/rubygems
export PERL5LIB=~/Sandbox/perl5/lib/perl5
export TZ=America/Toronto

#sentinel at the end is like 7x faster, for about half of so execution time
if [ "$path[-1]" != /var/empty/bogus/sentinel ]; then
  path=(/var/empty/bogus/sentinel)
  path=(/usr/local/sbin /usr/sbin /sbin /usr/libexec $path)
  path=(/usr/local/bin /usr/texbin /usr/bin /bin $path)
  path=(`find -L ~/.bin -maxdepth 1 -type d 2>&-` $path)
  export PATH
fi

export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.svgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.xz=01;31'
if ! PATH= whence compinit >&-; then
  autoload compinit
  compinit
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' completer _complete _ignored _match _correct _prefix _approximate
  zstyle ':completion:*' max-errors 2
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path ~/.zsh_cache
  zstyle ':completion:*:descriptions' format '%B%F{black}» %d%f%b'
  zstyle ':completion:*' group-name ''
fi

bindkey -e

prefset() {
  local key=$1 val; shift
    for val; do
    [ "${(P)key}" = "$val" ] && return
    whence -p "$val" >&- && break
  done
  export "$key=$val"
}

prefset EDITOR vim vi
prefset PAGER less more cat
export LESS=MR

whence gls >&- || alias gls=ls
alias brew='HOMEBREW_GITHUB_API_TOKEN=`< ~/.gist` brew'
alias gist='gist -p'
alias ls='LC_COLLATE=C gls --color=auto -FN'
alias mpv='mpv --screenshot-format=png --screenshot-template=%F-%P'
alias so='. ~/.zshrc'
alias vi='$EDITOR -O'

rm() {
  local arg
  if [ -n "${@[(r)-r]}" ]; then
    for arg; do
      [ -d "$arg" ] && find "$arg" -type d -name '*.git' -exec chmod -R u+w {}/objects \;
    done
  fi

  local rm
  for rm in grm rm; do
    which -p "$rm" >&- && break
  done

  command "$rm" -dv --one-file-system "$@"
}

dusort() { perl -E'%a=qw/G 9 M 6 K 3/;sub f{$_=pop;s/[GMK]/e$a{$&}/;$_}print sort{f($a)<=>f$b}<>' }
dudusort() { du -hd1 "$@" | dusort }

springe() { cat "$@" | ssh margot nc 127.0.0.1 2076 }
splurge() { pbpaste | springe }

attach-docker() {
  socat unix-listen:/tmp/docker.sock,fork exec:"ssh core@${1-manaka} socat - /run/docker.sock"
}
