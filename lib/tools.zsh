# Modern CLI tool aliases (brew-installed)

# eza (modern ls)
if (( ${+commands[eza]} )); then
  alias ls='eza --icons'
  alias ll='eza -alh --icons --git'
  alias la='eza -a --icons'
  alias lt='eza --tree --icons'
  alias l='eza --icons'
fi

# bat (modern cat)
if (( ${+commands[bat]} )); then
  alias cat='bat --paging=never'
  alias catp='bat'
fi
