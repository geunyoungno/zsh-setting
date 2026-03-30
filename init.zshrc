## == Init =====================================================================
export ZSHR=${0:a:h}

source ${ZSHR}/lib/bootstrap.zsh
BVFPATH=${ZSHR}/autoload
fpath+="${BVFPATH}"
if [[ -d "$BVFPATH" ]]; then
  for func in $BVFPATH/*; do
    autoload -Uz ${func:t}
  done
fi
unset BVFPATH

# If not Interactively.
case $- in
  *i*);;
  *) return 0;;
esac

# Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## == Zplugin Set ==============================================================
ZINIT_DIR=~/.zplugin/bin
ZINIT_BIN=${ZINIT_DIR}/zinit.zsh
source $ZINIT_BIN
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
autoload -Uz cdr
autoload -Uz chpwd_recent_dirs

## -- Theme Set ----------------------------------------------------------------
[[ ! -f ${ZSHR}/p10k.zsh ]] || source ${ZSHR}/p10k.zsh

## -- Plugin Set ---------------------------------------------------------------
if type tmux &>/dev/null; then
  export TMUX_ENABLE=true
fi

if type docker &>/dev/null; then
  export DOCKER_ENABLE=true
fi

if [[ -f "/mnt/c/WINDOWS/system32/wsl.exe" ]]; then
  # We're in WSL, which defaults to umask 0 and causes issues with compaudit
  umask 0022

  export WSL_ENABLE=true
fi

## -- Plugin Load --------------------------------------------------------------
## -- Oh-My-Zsh (cherry-picked) ----------------------------
ZSH="${ZINIT[PLUGINS_DIR]}/robbyrussell---oh-my-zsh"
local _OMZ_SOURCES=(
  lib/compfix.zsh
  lib/functions.zsh
  lib/termsupport.zsh

  plugins/command-not-found/command-not-found.plugin.zsh
  plugins/git/git.plugin.zsh
  plugins/gitfast/gitfast.plugin.zsh
  plugins/sudo/sudo.plugin.zsh
)
if [[ $TMUX_ENABLE ]]; then
  _OMZ_SOURCES=(
    $_OMZ_SOURCES
    plugins/tmux/tmux.plugin.zsh
  )
fi
if [[ $DOCKER_ENABLE ]]; then
  _OMZ_SOURCES=(
    $_OMZ_SOURCES
    plugins/docker/docker.plugin.zsh
    plugins/docker-compose/docker-compose.plugin.zsh
  )
fi

zinit ice from"gh" pick"/dev/null" nocompletions blockf lucid \
        multisrc"${_OMZ_SOURCES}" compile"(${(j.|.)_OMZ_SOURCES})" wait"1c"
zinit light robbyrussell/oh-my-zsh

## -- Core Plugins -----------------------------------------
zinit ice depth"1"
zinit light romkatv/powerlevel10k

zinit ice wait"0a" atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" atload"_zsh_highlight" lucid
zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice wait"0a" compile'{src/*.zsh,src/strategies/*}' atload"_zsh_autosuggest_start" lucid
zinit light zsh-users/zsh-autosuggestions
zinit ice wait"0b" lucid
zinit light hlissner/zsh-autopair
zinit ice wait"0b" blockf lucid
zinit light zsh-users/zsh-completions

## -- FZF (brew) + fzf-tab --------------------------------
local BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
zinit ice wait"0c" lucid
zinit snippet "${BREW_PREFIX}/opt/fzf/shell/completion.zsh"
zinit ice wait"0c" lucid
zinit snippet "${BREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
zinit ice wait"0c" lucid
zinit light Aloxaf/fzf-tab

## -- Zoxide (brew) ----------------------------------------
zinit ice wait"0c" atload'eval "$(zoxide init zsh)"' lucid
zinit light zdharma-continuum/null

## -- Tools ------------------------------------------------
zinit ice wait"1" lucid
zinit light wfxr/forgit
zinit ice wait"1" lucid
zinit light peterhurford/up.zsh

load-file ~/.zplugins.local

## -- Library Setting --------------------------------------
zinit ice wait multisrc"lazyenv.zsh completion.zsh fzf.zsh tools.zsh" lucid
zinit light $ZSHR/lib

_zpcompinit-custom
zinit cdreplay -q

## == From bashrc ==============================================================
# Linux color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
fi

## == Custom Set ===============================================================
setopt nonomatch
setopt interactive_comments
setopt correct
setopt noclobber
setopt complete_aliases
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=10000000
SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# eliminates duplicates in *paths
typeset -gU cdpath fpath path


# Alias
alias tar-compress-gz="tar -zcvf"
alias tar-extract-gz="tar -zxvf"
alias map="telnet mapscii.me"
(( ${+commands[prettyping]} )) && alias prettyping="prettyping"
alias rsync-ssh="rsync -avzhe ssh --progress"
alias ~="cd ~"
alias /="cd /"
alias ..="cd .."
alias ...="cd ../../../"
alias ....="cd ../../../../"
alias .....="cd ../../../../../"
alias rm="rm -i"                          # confirm before overwriting something
alias cp="cp -i"
alias mv="mv -i"
alias df="df -h"                          # human-readable sizes
(( ${+commands[free]} )) && alias free='free -m'
alias more=less
alias bc="bc -l"
alias sha1="openssl sha1"
#alias open="xdg-open"

# Apple Terminal New Tab
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]
then
  function chpwd {
    printf '\e]7;%s\a' "file://$HOSTNAME${PWD// /%20}"
  }

  chpwd
fi

## -- Local Settings -----------------------------------------------------------
[[ -f ${ZSHR}/local.zsh ]] && source ${ZSHR}/local.zsh
