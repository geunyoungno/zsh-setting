##-------------------------FZF set
##-----Color Scheme
export FZF_DEFAULT_OPTS="
    --color fg:-1,bg:-1,hl:196,fg+:254,bg+:239,hl+:040
    --color info:226,prompt:226,pointer:196,marker:254,spinner:226
  "

zle     -N    _fzf-readline
bindkey '^x1' _fzf-readline

alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'

if [[ $TMUX_ENABLE ]] then
    export FZF_TMUX=1
fi

#Directly executing the command (CTRL-X CTRL-R)
zle     -N     fzf-history-widget-accept
bindkey '^X^R' fzf-history-widget-accept

export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_OPTS="--preview '(bat --style=numbers --color=always {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

##-----Completion
#Git
_fzf_complete_git()
{
    ARGS="$@"
    local branches
    branches=$(git branch -vv --all)
    if [[ $ARGS == 'git co'* ]]; then
        _fzf_complete "--reverse --multi" "$@" < <(
            echo $branches
        )
    else
        eval "zle ${fzf_default_completion:-expand-or-complete}"
    fi
}
_fzf_complete_git_post()
{
    awk '{print $1}'
}
