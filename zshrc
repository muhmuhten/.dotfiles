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
	print -P "%B%F{yellow}(%n@${HOST%.local*}) %F{blue}[%D %*] %F{green}[%!] %F{magenta}(%?) %F{cyan}(%~)%f"

	case $TERM in
		screen) print -Pn "\ek%~\e\\" ;;
		xterm*) print -Pn "\e]1;%n@%m:%~\a" ;;
	esac
}
PS1='%B%#%b '
PS2=$PS1
bindkey -e

export HOME=$HOME:A
cd . # chase links

export DOCKER_HOST=${DOCKER_HOST-unix:///tmp/docker.sock}
export GEM_HOME=~/Sandbox/rubygems
export PERL5LIB=~/Sandbox/perl5/lib/perl5

zmodload -F zsh/stat b:zstat
zstat -H bintime +mtime ~/.bin
#sentinel at the end is like 7x faster, for about half of so execution time
if [ "${path[-1]##*/}" != "$bintime" ]; then
	path=("/var/empty/sentinel/$bintime")
	path=(/usr/local/sbin /usr/sbin /sbin $path)
	path=(/usr/local/bin /usr/bin /bin $path)
	path=(`find -L ~/.bin -maxdepth 1 -type d 2>&-` $path)
	export PATH
fi
unset bintime

whence vim >&- && EDITOR=vim || EDITOR=vi
export EDITOR PAGER=less LESS=MR
export CLICOLOR=1 TZ=America/Toronto

# these two schemes are vastly identical, but translation is nontrivial
export LSCOLORS=ExGxFxDxCxDbDeCbCeHeHb
list_colors='di=1;34 ln=1;36 or=1;36;40 mi=1;31 so=1;35 pi=1;33 ex=1;32 bd=1;33;41 cd=1;33;44 su=1;32;41 sg=1;32;44 tw=1;37;44 ow=1;37;41'

export LS_COLORS=${list_colors// /:}
if ! PATH= whence compinit >&-; then
	autoload compinit
	compinit -d ~/".zsh${ZSH_VERSION}_compdump@$HOST"
	zstyle ':completion:*' cache-path ~/".${ZSH_PATCHLEVEL}_compcache@$HOST"
	zstyle ':completion:*' use-cache on
	zstyle ':completion:*' completer _complete _ignored _match _correct _prefix _approximate
	zstyle ':completion:*' max-errors 2
	zstyle ':completion:*' list-colors ${(s: :)list_colors}
	zstyle ':completion:*:descriptions' format '%F{blue}# %d%f%b'
	zstyle ':completion:*' group-name ''
fi
unset list_colors

case $OSTYPE in
	darwin*|freebsd*)
		# BSD ls
		alias ls='ls -F'
		;;
	linux-*)
		alias ls='ls --color=auto -FN'
		;;
esac
[ "$EDITOR" = vim ] && alias vi='vim -O'

alias brew='HOMEBREW_NO_ANALYTICS=1 HOMEBREW_GITHUB_API_TOKEN=`< ~/.gist` brew'
alias gist='gist -p'
alias mpv='mpv --screenshot-format=png --screenshot-template=%F-%P'
alias rm='rm -dv'
alias so='. ~/.zshrc'
alias sudo='sudo '

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

dudusort() { du -hd1 "$@" | sort -h }

springe() { cat "$@" | curl -F 'sprunge=<-' http://sprunge.us }
splurge() { pbpaste | springe }

attach-docker() {
	socat unix-listen:/tmp/docker.sock,fork exec:"ssh core@${1-manaka} socat - /run/docker.sock"
}
