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

# these two schemes are vastly identical, but translation is nontrivial
export LSCOLORS=ExGxFxDxCxDbDeCbCeHbHe
list_colors='di=1;34 ln=1;36 or=1;36;40 mi=1;31 so=1;35 pi=1;33 ex=1;32 bd=1;33;41 cd=1;33;44 su=1;32;41 sg=1;32;44 ow=1;37;41'
export LS_COLORS=${list_colors// /:}
if ! PATH= whence compinit >&-; then
	autoload compinit
	compinit
	zstyle ':completion:*' use-cache on
	zstyle ':completion:*' cache-path ~/.zsh_cache
	zstyle ':completion:*' completer _complete _ignored _match _correct _prefix _approximate
	zstyle ':completion:*' max-errors 2
	zstyle ':completion:*' list-colors ${(s: :)list_colors}
	zstyle ':completion:*:descriptions' format '%F{blue}# %d%f%b'
	zstyle ':completion:*' group-name ''
fi
unset list_colors

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
[ "$PAGER" = less ] && export LESS=MR

alias brew='HOMEBREW_GITHUB_API_TOKEN=`< ~/.gist` brew'
alias gist='gist -p'
alias ls='ls -F'
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

springe() { cat "$@" | curl -F 'sprunge=<-' http://sprunge.us }
splurge() { pbpaste | springe }

attach-docker() {
	socat unix-listen:/tmp/docker.sock,fork exec:"ssh core@${1-manaka} socat - /run/docker.sock"
}
