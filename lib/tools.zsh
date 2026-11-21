# Modern CLI tool aliases (brew-installed)

# eza (modern ls)
if (( ${+commands[eza]} )); then
  alias ls='eza --icons=auto'
  alias ll='eza -alh --icons=auto --git'
  alias la='eza -a --icons=auto'
  alias lt='eza --tree --icons=auto'
  alias l='eza --icons=auto'
fi

# bat (modern cat)
if (( ${+commands[bat]} )); then
  alias cat='bat --paging=never'
  alias catp='bat'
fi
