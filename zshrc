setopt auto_pushd chase_links extended_glob interactive_comments
setopt magic_equal_subst multios rc_quotes rm_star_silent
setopt hist_ignore_space hist_reduce_blanks share_history extended_history

export HOME=$HOME:A
cd . # chase links
export GEM_HOME=~/Sandbox/rubygems
export PERL5LIB=~/Sandbox/perl5/lib/perl5
export PKG_CONFIG_PATH=~/Sandbox/pkg-config
export LUA_INIT='getmetatable"".__mod = string.format'
export TZ=America/Toronto

path=(~/.bin/*(N-/) ~/Sandbox/*/bin(N) /{usr/local/,,usr/}{s,}bin)
export PATH

manpath=(~/Sandbox/*/share/man(N) "")
export MANPATH

if [ ! ${HISTFILE+1} ]; then
	HISTFILE=~/.zsh_history
	: >> "$HISTFILE"
	HISTSIZE=$((`wc -l < "$HISTFILE"`))
fi
# okay I have no idea what to do here so give it a generous buffer
zshaddhistory() ((HISTSIZE = SAVEHIST = HISTCMD*2+1000000))

precmd() {
	print -P "%B%F{yellow}(%n@%m) %F{blue}[%D{%F %T}] %F{green}[%!] %F{magenta}(%?) %F{cyan}(%~)%f"
	case ${TMUX+1}$TERM in
	(1*)
		print -Pn '\ek%~\e\' ;;
	(screen)
		print -Pn '\ek%n@%m:%~\e\' ;;
	(*)
		print -Pn '\e]2;%n@%m:%~\a' ;;
	esac >&2
}
PS1='%B%#%b '
PS2=$PS1
bindkey -e
# mintty alt-Right/Left
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word
TMPPREFIX=${TMPPREFIX%/*}/$$:
WORDCHARS=

case $FPATH in
~/*) ;;
*) fpath=(~/.dotfiles/zsh_functions_ $fpath)  ;;
esac

if ! PATH= command -v compinit > /dev/null; then
	autoload compinit
	case $UID,$OSTYPE in
	0,*) compinit -D -i ;;
	*,darwin) compinit -d ~/".${ZSH_PATCHLEVEL}_compdump-$USER@$HOST" -u ;;
	*,*) compinit -d ~/".${ZSH_PATCHLEVEL}_compdump-$USER@$HOST" -i ;;
	esac
fi

list_colors='di=1;34 ln=1;36 or=1;36;40 mi=1;31 so=1;35 pi=1;33 ex=1;32 bd=1;33;41 cd=1;33;44 su=1;32;41 sg=1;32;44 tw=1;37;44 ow=1;37;41'
zstyle ':completion:*' cache-path ~/".${ZSH_PATCHLEVEL}_compcache-$USER@$HOST"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' completer _complete _ignored _match _correct _prefix _approximate
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' list-colors ${(s: :)list_colors}
zstyle ':completion:*:descriptions' format '%F{blue}# %d%f%b'
zstyle ':completion:*' group-name ''

case $OSTYPE in
darwin*)
	export RSYNC_ICONV=utf-8-mac,utf-8
	alias brew='HOMEBREW_NO_ANALYTICS=1 sudo -iu cleric brew'
	alias sudo='sudo -u cleric sudo '
	;&
freebsd*)
	# BSD ls; largely identical colour scheme, but translation is nontrivial
	export CLICOLOR=1 LSCOLORS=ExGxFxDxCxDbDeCbCeHeHb
	export TAPE=- # default file for tar
	alias ls='env LC_COLLATE=C ls -F'
	;;
linux-android)
	path=(~/.bin/*(N-/) ~/Sandbox/*/bin(N) /data/data/com.termux/files/usr/bin{,/applets})
	zstyle ':completion:*' accept-exact-dirs on
	zstyle ':completion:*' fake-files /:sdcard /:data /data:data /data/data:com.termux
	;&
linux-*|msys)
	# GNU ls, hopefully; busybox lacks -N, but it's not worth testing for
	export LS_COLORS="${list_colors// /:}"
	alias ls="ls --color=auto -FN"
	;;
esac
unset list_colors

command -v vim > /dev/null && EDITOR=vim || EDITOR=vi
[ "$EDITOR" = vim ] && alias vi='vim -O'
export EDITOR PAGER=less LESS=MR

alias so='. ~/.zshrc'
alias doas='doas '
command -v sudo > /dev/null && alias doas='sudo '

rm() {
	# avoid rm -r prompting when the only read-only things are git objects
	local arg
	if [ -n "${@[(r)-r]}" ]; then # checks if "-r" appears among the flags
		for arg; do
			# I mean ok, if there's a dir named "-r", we'll try to chmod -r/.git &c....
			[ -d "$arg" ] && find "$arg" -type d -name '*.git' -exec chmod -R u+w {}/objects \;
		done
	fi

	# breaks on busybox rm, but that's not a big deal
	command rm -dv "$@"
}

dudusort() {
	if command -v gsort > /dev/null; then
		du -hd1 "$@" | gsort -h
	else
		du -hd1 "$@" | sort -h
	fi
}

with_closest() {
	local dir file; dir=$PWD/; file=$1; shift
	while case $dir in (/*/*) ;; (*) ! esac; do
		dir=${dir%/*}
		[ -f "$dir/$file" ] || continue
		(HOME=$dir exec "$@")
		return
	done
	"$@"
}

make() {
	local cmd
	if [ -f BSDmakefile ]; then
		cmd=bmake
		set ".MAKE.MAKEFILE_PREFERENCE = BSDMakefile makefile Makefile" "$@"
	elif [ -f GNUmakefile ]; then
		cmd=gmake
	fi
	command -v "$cmd" > /dev/null || cmd=make
	command "$cmd" "$@"
}

git() with_closest .gitconfig command git "$@"
