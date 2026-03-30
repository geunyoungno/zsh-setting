## == Lazy Environment Loader ===================================================
local BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# fnm (fast node manager)
if (( ${+commands[fnm]} )); then
  eval "$(fnm env --use-on-cd)"
fi

# kubectl completion
if (( ${+commands[kubectl]} )); then
  source <(kubectl completion zsh)
fi

# brew fpath
if [[ -d "${BREW_PREFIX}/share/zsh/site-functions" ]]; then
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"
fi
