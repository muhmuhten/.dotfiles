setopt auto_pushd chase_links extended_glob interactive_comments
setopt magic_equal_subst multios rc_quotes rm_star_silent
setopt hist_ignore_dups hist_ignore_space hist_reduce_blanks
setopt share_history extended_history

export HOME=$HOME:A
cd . # chase links
export GEM_HOME=~/Sandbox/rubygems
export PERL5LIB=~/Sandbox/perl5/lib/perl5
export TZ=America/Toronto

zmodload -F zsh/stat b:zstat
zstat -H bintime +mtime ~/.bin
#sentinel at the end is like 7x faster, for about half of so execution time
if [ "$dyntime" != "$bintime" ]; then
	dyntime=$bintime
	dynpath=(`find -L ~/.bin -maxdepth 1 -type d 2>&-`)
fi
unset bintime
path=($dynpath /{usr/{local/,},}{s,}bin)
export PATH

if [ ! ${HISTFILE+1} ]; then
	HISTFILE=~/.zsh_history
	: >> "$HISTFILE"
	HISTSIZE=$((`wc -l < "$HISTFILE"`))
fi
# HISTCMD still refers to previous entry, so need at least +1 to avoid losing
# the oldest entry; extra safety margin is in case I misunderstood something;
# the minor memory cost is negligible in comparison
zshaddhistory() ((HISTSIZE = SAVEHIST = HISTCMD+10))

precmd() {
	print -P "%B%F{yellow}(%n@%m) %F{blue}[%D %*] %F{green}[%!] %F{magenta}(%?) %F{cyan}(%~)%f"

	case $TERM in
		screen) print -Pn "\ek%~\e\\" ;;
		xterm*) print -Pn "\e]1;%n@%m:%~\a" ;;
	esac
}
PS1='%B%#%b '
PS2=$PS1
bindkey -e
TMPPREFIX=${TMPPREFIX%/*}/$$:
WORDCHARS=

if ! PATH= whence compinit >&-; then
	autoload compinit
	compinit -d ~/".${ZSH_PATCHLEVEL}_compdump@$HOST"
fi

list_colors='di=1;34 ln=1;36 or=1;36;40 mi=1;31 so=1;35 pi=1;33 ex=1;32 bd=1;33;41 cd=1;33;44 su=1;32;41 sg=1;32;44 tw=1;37;44 ow=1;37;41'
zstyle ':completion:*' cache-path ~/".${ZSH_PATCHLEVEL}_compcache@$HOST"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' completer _complete _ignored _match _correct _prefix _approximate
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' list-colors ${(s: :)list_colors}
zstyle ':completion:*:descriptions' format '%F{blue}# %d%f%b'
zstyle ':completion:*' group-name ''

case $OSTYPE in
	darwin*)
		alias brew='HOMEBREW_NO_ANALYTICS=1 HOMEBREW_GITHUB_API_TOKEN=`< ~/.gist` brew'
		alias gist='gist -p'
		alias mpv='mpv --screenshot-format=png --screenshot-template=%F-%P'
		;&
	freebsd*)
		# BSD ls; largely identical colour scheme, but translation is nontrivial
		export CLICOLOR=1 LSCOLORS=ExGxFxDxCxDbDeCbCeHeHb
		alias ls='ls -F'
		;;

	linux-*)
		# GNU ls, hopefully; busybox lacks -N, but it's not worth testing for
		export LS_COLORS="${list_colors// /:}"
		alias ls="ls --color=auto -FN"
		;;
esac
unset list_colors

whence vim >&- && EDITOR=vim || EDITOR=vim
export EDITOR PAGER=less LESS=MR

[ "$EDITOR" = vim ] && alias vi='vim -O'

alias rm='rm -dv'
alias so='. ~/.zshrc'
alias doas='doas '

rm() {
	# avoid rm -r prompting when the only read-only things are git objects
	local arg
	if [ -n "${@[(r)-r]}" ]; then
		for arg; do
			[ -d "$arg" ] && find "$arg" -type d -name '*.git' -exec chmod -R u+w {}/objects \;
		done
	fi

	# breaks on busybox rm, but that's not a big deal
	command rm "$@"
}

doas() {
	unfunction doas
	if whence -p doas >&-; then
		command doas "$@"
	else
		alias doas='sudo '
		command sudo "$@"
	fi
}

dudusort() {
	local sort=(sort -h)
	whence gsort >&- && sort[1]=gsort
	du -hd1 "$@" | $sort
}

springe() { cat "$@" | curl -F 'sprunge=<-' http://sprunge.us }
splurge() { pbpaste | springe }
