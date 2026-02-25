# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Makes the local symlinks commands ref work.
export PATH="$HOME/.dotnet/tools:$HOME/.local/bin:$PATH"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Zinit plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  mkdir -p "${ZINIT_HOME:h}"
  if (( $+commands[git] )); then
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" >/dev/null 2>&1
  fi
fi

if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  # Plugin manager handles fetch/update from these declarations.
  zinit snippet OMZP::git
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zsh-users/zsh-completions
  zinit light romkatv/powerlevel10k
  zinit ice nocompile
  zinit light catppuccin/zsh-syntax-highlighting

  # Warn when Docker completion symlink is broken (common when Docker Desktop
  # on Windows host is stopped), but do not mutate system files/fpath.
  if [[ -L /usr/share/zsh/vendor-completions/_docker ]] && [[ ! -e /usr/share/zsh/vendor-completions/_docker ]]; then
    echo "[zsh] Warning: Docker vendor completions may be unavailable while Docker Desktop is stopped on the Windows host." >&2
  fi

  autoload -Uz compinit
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

  CATPPUCCIN_THEME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/plugins/catppuccin---zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh"
  [[ -f "$CATPPUCCIN_THEME" ]] && source "$CATPPUCCIN_THEME"
fi


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# -------------------------------------------
# 1. Edit Command Buffer
# -------------------------------------------
# Use VS Code for command-line editing (Ctrl+X then Ctrl+E)
if (( $+commands[code] )); then
  export VISUAL="code --wait"
  export EDITOR="$VISUAL"
fi

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Directory navigation behavior from previous OMZ setup.
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

# Preserve legacy aliases from previous non-git-managed setup.
if (( $+commands[eza] )); then
  alias ls='eza --icons'
  alias ll='eza -lah --icons'
  alias la='eza -a --icons'
else
  alias ls='ls --color=auto'
  alias ll='ls -alF --color=auto'
  alias la='ls -A --color=auto'
fi
(( $+commands[bat] )) && alias cat='bat'
(( $+commands[fd] )) && alias find='fd'

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Example: List directory contents on cd

chpwd() {
  ls
}

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f "${ZDOTDIR:-$HOME/.config/zsh}/.p10k.zsh" ]] || source "${ZDOTDIR:-$HOME/.config/zsh}/.p10k.zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Custom copy and paste functions
pbpaste() {
  xclip -selection clipboard -o
}

pbcopy() {
  xclip -selection clipboard
}

eval "$(zoxide init --cmd cd zsh)"

# Copy current command buffer to system clipboard via xclip
function copy-buffer-to-clipboard() {
  echo -n "$BUFFER" | xclip -selection clipboard
  zle -M "Copied to clipboard"
}

zle -N copy-buffer-to-clipboard
bindkey '^Xc' copy-buffer-to-clipboard

bindkey '^p' history-search-backward 
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
mkdir -p "${HISTFILE:h}"
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# -------------------------------------------
# 5. Suffix Aliases - Open Files by Extension
# -------------------------------------------
# Just type the filename to open it with the associated program
alias -s json=fx
alias -s md=bat
alias -s txt=bat
alias -s log=bat
alias -s p='$EDITOR'
alias -s i='$EDITOR'
alias -s cls='$EDITOR'

# -------------------------------------------
# 7. zmv - Advanced Batch Rename/Move
# -------------------------------------------
# Enable zmv
autoload -Uz zmv

# Usage examples:
# zmv '(*).log' '$1.txt'           # Rename .log to .txt
# zmv -w '*.log' '*.txt'           # Same thing, simpler syntax
# zmv -n '(*).log' '$1.txt'        # Dry run (preview changes)
# zmv -i '(*).log' '$1.txt'        # Interactive mode (confirm each)

# Machine-local overrides (not tracked by git)
if [[ -f "${ZDOTDIR:-$HOME/.config/zsh}/local.zsh" ]]; then
  source "${ZDOTDIR:-$HOME/.config/zsh}/local.zsh"
fi
