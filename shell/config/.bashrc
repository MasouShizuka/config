# ╭─────────────────────╮
# │ Running Environment │
# ╰─────────────────────╯

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

is_windows=0
is_mac=0
is_linux=0
is_wsl=0
uname=$(uname -a | tr '[:upper:]' '[:lower:]')
case "$uname" in
mingw*)
    is_windows=1
    ;;
*msys)
    is_windows=1
    ;;
darwin*)
    is_mac=1
    ;;
*wsl*)
    is_linux=1
    is_wsl=1
    ;;
linux*)
    is_linux=1
    ;;
esac

if ((is_wsl)); then
    appdata=$(wslpath "$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')")
    localappdata=$(wslpath "$(cmd.exe /c "echo %LOCALAPPDATA%" 2>/dev/null | tr -d '\r')")
    userprofile=$(wslpath "$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')")
fi

# ╭───────╮
# │ Alias │
# ╰───────╯

alias ..="cd .."         # Go up one directory
alias ...="cd ../.."     # Go up two directories
alias ....="cd ../../.." # Go up three directories

alias dus="du --max-depth=1 --human-readable | sort --human-numeric-sort --reverse"

alias q=exit

alias grep="grep --color=auto"

alias ls="ls --color=auto"
alias ll="ls --all --human-readable -l --time-style=long-iso"

# ╭──────────────────────╮
# │ Environment Variable │
# ╰──────────────────────╯

[[ -d "$HOME/.local/bin" ]] && export PATH="$PATH:$HOME/.local/bin"

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

if [[ -x "$(command -v nvim)" ]]; then
    export EDITOR=nvim
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if ((is_windows)); then
    export MSYS=winsymlinks:nativestrict
    export MSYS2_PATH_TYPE=inherit
fi

# ╭──────────╮
# │ Function │
# ╰──────────╯

function myip() {
    list=("http://myip.dnsomatic.com/" "http://checkip.dyndns.com/" "http://checkip.dyndns.org/")
    for url in "${list[@]}"; do
        if res="$(curl -fs "${url}")"; then
            break
        fi
    done
    res="$(echo "$res" | grep -Eo '[0-9\.]+')"
    echo -e "Your public IP is: ${echo_bold_green-} $res ${echo_normal-}"
}

function quiet() {
    nohup "$@" &>/dev/null </dev/null &
}

# ╭────────────╮
# │ Keybinding │
# ╰────────────╯

set -o vi
bind "set show-mode-in-prompt on"
bind "set vi-cmd-mode-string \1\e[2 q\2"
bind "set vi-ins-mode-string \1\e[6 q\2"

bind "set bind-tty-special-chars off"

# H:Move to the start of the current line.
bind -m vi-command "H:beginning-of-line"
# L:Move to the end of the line.
bind -m vi-command "L:end-of-line"

# s-left: Move forward to the end of the next word. Words are delimited by non-quoted shell metacharacters.
bind '"\e[1;2D":shell-backward-word'
# s-right: Move back to the start of the current or previous word. Words are delimited by non-quoted shell metacharacters.
bind '"\e[1;2C":shell-forward-word'

# c-l: Clear the screen, then redraw the current line, leaving the current line at the top of the screen.
bind '"\C-l":clear-screen'
bind -m vi-command "Control-l:clear-screen"

# up/k: Search backward through the history for the string of characters between the start of the current line and the point.
bind '"\e[A":history-search-backward'
bind -m vi-command "k:history-search-backward"
# down/j: Search forward through the history for the string of characters between the start of the current line and the point.
bind '"\e[B":history-search-forward'
bind -m vi-command "j:history-search-forward"

# c-w: Kill the word behind point. Word boundaries are the same as shell-backward-word.
bind '"\C-w":shell-backward-kill-word'
bind -m vi-command "Control-w:shell-backward-kill-word"

# tab 相关
bind "set completion-ignore-case on"
bind "set mark-symlinked-directories on"
bind "set show-all-if-unmodified on"
shopt -s no_empty_cmd_completion

# ╭─────────╮
# │ Setting │
# ╰─────────╯

blue="\[\e[38;2;130;170;255m\]"
cyan="\[\e[38;2;79;214;190m\]"
green="\[\e[38;2;195;232;141m\]"
purple="\[\e[38;2;252;167;234m\]"

bold="\[\e[1m\]"
reset="\[\e[0m\]"

if ((is_windows)); then
    PS1="${blue}󰍲 "
elif ((is_mac)); then
    PS1="${blue} "
else
    PS1="${blue} "
fi
PS1="$PS1$bold$cyan\w ${reset}at $bold$purple\t$green\n $reset"

[[ -z "$HISTFILE" ]] && HISTFILE="$HOME/.bash_history"
HISTSIZE=50000

LAST_COMMAND=""
# This will run before any command is executed.
function preexec() {
    if [[ -z "$AT_PROMPT" ]]; then
        return
    else
        unset AT_PROMPT
    fi

    if [[ "$BASH_COMMAND" == "$PROMPT_COMMAND" ]]; then
        LAST_COMMAND=""
        return
    else
        LASTHIST=$(history 1 | sed 's/^\s*[0-9]*\s*//')
        LAST_COMMAND=$LASTHIST
    fi
}
trap "preexec" DEBUG

# Don't record history to $HISTFILE when the window is closed
trap "unset HISTFILE; exit" SIGHUP

# This will run after the execution of the previous full command line.  We don't
# want it PostCommand to execute when first starting a bash session (i.e., at
# the first prompt).
FIRST_PROMPT=1
function precmd() {
    if (($? == 0)); then
        is_succeeded=1
    else
        is_succeeded=0
    fi

    AT_PROMPT=1
    if [[ -n "$FIRST_PROMPT" ]]; then
        unset FIRST_PROMPT
        return
    fi

    if ((is_succeeded)); then
        LASTHIST=${LAST_COMMAND%%$'\n'}
        LASTHIST=${LASTHIST#"${LASTHIST%%[![:space:]]*}"}
        LASTHIST=${LASTHIST%"${LASTHIST##*[![:space:]]}"}
        if [[ -n "$LASTHIST" ]]; then
            LASTHIST=${LASTHIST//\\//}
            LASTHIST_SED=$(<<<"$LASTHIST" sed -e 's`[][\\/.*^$]`\\&`g')
            sed -i "{/^${LASTHIST_SED}$/d;}" "$HISTFILE"
            echo "$LASTHIST" >>"$HISTFILE"
        fi
    fi
}
PROMPT_COMMAND="precmd"

# ╭───────────────────╮
# │ Command Line Tool │
# ╰───────────────────╯

# ╭─ bottom ─────────────────────────────────────────────────╮

[[ -x "$(command -v btm)" ]] && alias b=btm

# ╰───────────────────────────────────────────────── bottom ─╯

# ╭─ conda ──────────────────────────────────────────────────╮

if [[ -x "$(command -v mamba)" ]]; then
    if ((is_windows)); then
        # https://github.com/zou-group/textgrad/issues/139
        export PYTHONUTF8=1

        CONDA_EXE="$HOME/scoop/apps/mambaforge/current/Scripts/conda.exe"
        if [[ -f "$CONDA_EXE" ]]; then
            eval "$("$CONDA_EXE" "shell.bash" "hook")"
        fi
        MAMBA_SH="$HOME/scoop/apps/mambaforge/current/etc/profile.d/mamba.sh"
        if [[ -f "$MAMBA_SH" ]]; then
            . "$MAMBA_SH"
        fi
    fi
fi

# ╰────────────────────────────────────────────────── conda ─╯

# ╭─ fzf ────────────────────────────────────────────────────╮

if [[ -x "$(command -v fzf)" ]]; then
    export FZF_COMPLETION_TRIGGER="\\"
    export FZF_DEFAULT_OPTS="
        --height=80%
        --layout=reverse
        --border=rounded
        --cycle
        --scroll-off=5
        --info=inline
        --preview='bat --number --color always --theme ansi --line-range :500 {}'
        --preview-border=rounded
        --bind=ctrl-i:accept,ctrl-d:page-down,ctrl-u:page-up,ctrl-f:preview-down,ctrl-b:preview-up
    "

    # Tokyo Night Moon
    # https://github.com/folke/tokyonight.nvim/blob/main/extras/fzf/tokyonight_moon.sh
    export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
        --color=border:#589ed7
        --color=fg:#c8d3f5
        --color=gutter:#1e2030
        --color=header:#ff966c
        --color=hl+:#65bcff
        --color=hl:#65bcff
        --color=info:#545c7e
        --color=marker:#ff007c
        --color=pointer:#ff007c
        --color=prompt:#65bcff
        --color=query:#c8d3f5:regular
        --color=scrollbar:#589ed7
        --color=separator:#ff966c
        --color=spinner:#ff007c
    "

    # Set up fzf key bindings and fuzzy completion
    eval "$(fzf --bash)"
fi

# ╰──────────────────────────────────────────────────── fzf ─╯

# ╭─ lazygit ────────────────────────────────────────────────╮

[[ -x "$(command -v lazygit)" ]] && alias lg=lazygit

# ╰──────────────────────────────────────────────── lazygit ─╯

# ╭─ neovim ─────────────────────────────────────────────────╮

if [[ -x "$(command -v nvim)" ]]; then
    alias v=nvim

    if ((is_wsl)); then
        if [[ ! -d "$HOME/.config/nvim" ]]; then
            if [[ ! -d "$HOME/.config" ]]; then
                mkdir -p "$HOME/.config"
            fi
            ln -s "$localappdata/nvim" "$HOME/.config/nvim"
        fi
    fi
fi

# ╰───────────────────────────────────────────────── neovim ─╯

# ╭─ yazi ───────────────────────────────────────────────────╮

if [[ -x "$(command -v yazi)" ]]; then
    if ((is_wsl)); then
        if [[ ! -d "$HOME/.config/yazi" ]]; then
            if [[ ! -d "$HOME/.config" ]]; then
                mkdir -p "$HOME/.config"
            fi
            ln -s "$appdata/yazi/config" "$HOME/.config/yazi"
        fi
    fi

    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

# ╰─────────────────────────────────────────────────── yazi ─╯

# ╭─ zellij ─────────────────────────────────────────────────╮

if [[ -x "$(command -v zellij)" ]]; then
    alias z=zellij
    alias Z="zellij attach -c default"

    if ((is_wsl)); then
        if [[ ! -d "$HOME/.config/zellij" ]]; then
            if [[ ! -d "$HOME/.config" ]]; then
                mkdir -p "$HOME/.config"
            fi
            ln -s "$userprofile/.config/zellij" "$HOME/.config/zellij"
        fi
    fi
fi

# ╰───────────────────────────────────────────────── zellij ─╯
