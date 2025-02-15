# ╭─────────────────────╮
# │ Running Environment │
# ╰─────────────────────╯

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return ;;
esac

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



# ╭───────╮
# │ Alias │
# ╰───────╯

alias ls="ls --color=auto"
alias ll="ls -al -h --time-style=long-iso"

alias grep="grep --color=auto"

alias q=exit

alias ..="cd .."         # Go up one directory
alias ...="cd ../.."     # Go up two directories
alias ....="cd ../../.." # Go up three directories



# ╭──────────────────────╮
# │ Environment Variable │
# ╰──────────────────────╯

if [[ -x "$(command -v nvim)" ]]; then
    export EDITOR=nvim
    export GIT_EDITOR=nvim
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
    nohup "$@" &> /dev/null < /dev/null &
}



# ╭────────────╮
# │ keybinding │
# ╰────────────╯

# enter a few characters and press UpArrow/DownArrow
# to search backwards/forwards through the history
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# 移动到上/下一个单词
bind '"\e[1;2D":backward-word'
bind '"\e[1;2C":forward-word'



# ╭─────────╮
# │ Setting │
# ╰─────────╯

if [[ -z "$HISTFILE" ]]; then
    HISTFILE="$HOME/.bash_history"
fi
HISTSIZE=50000

LAST_COMMAND=""
# This will run before any command is executed.
function preexec() {
    if [ -z "$AT_PROMPT" ]; then
        return
    fi
    unset AT_PROMPT

    if [[ -z ${BASH_COMMAND//[[:space:]]/} ]]; then
        return
    fi

    LASTHIST=$(history 1 | sed 's/^\s*[0-9]*\s*//')

    if [[ "$LASTHIST" == "$LAST_COMMAND" ]]; then
        return
    fi
    LAST_COMMAND=$LASTHIST

    LASTHIST_SLASH=${LASTHIST//\\//}

    LASTHIST_TRIM=${LASTHIST_SLASH%%$'\n'}
    LASTHIST_TRIM=${LASTHIST_TRIM#"${LASTHIST_TRIM%%[![:space:]]*}"}
    LASTHIST_TRIM=${LASTHIST_TRIM%"${LASTHIST_TRIM##*[![:space:]]}"}

    LASTHIST_SED=$(<<<"$LASTHIST_TRIM" sed -e 's`[][\\/.*^$]`\\&`g')
    sed -i "{/^${LASTHIST_SED}$/d;}" "$HISTFILE"

    echo "$LASTHIST_TRIM" >>"$HISTFILE"
}
trap "preexec" DEBUG

# This will run after the execution of the previous full command line.  We don't
# want it PostCommand to execute when first starting a bash session (i.e., at
# the first prompt).
FIRST_PROMPT=1
function precmd() {
    AT_PROMPT=1

    if [ -n "$FIRST_PROMPT" ]; then
        unset FIRST_PROMPT
        return
    fi
}
PROMPT_COMMAND="precmd"



# ╭───────────────────╮
# │ Command Line Tool │
# ╰───────────────────╯

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
        --bind=ctrl-i:accept
    "

    # # One Dark
    # export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
    #     --color=dark
    #     --color=fg:-1,bg:-1,hl:#c678dd,fg+:#abb2bf,bg+:#282c34,hl+:#c678dd
    #     --color=info:#98c379,prompt:#61afef,pointer:#e06c75,marker:#e5c07b,spinner:#61afef,header:#61afef"
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

if [[ -x "$(command -v lazygit)" ]]; then
    alias lg=lazygit
fi

# ╰──────────────────────────────────────────────── lazygit ─╯


# ╭─ neovim ─────────────────────────────────────────────────╮

if [[ -x "$(command -v nvim)" ]]; then
    alias vi=nvim
    alias vim=nvim

    if ((is_wsl)); then
        if [[ ! -d "$HOME/.config/nvim" ]]; then
            localappdata=$(wslpath "$(cmd.exe /c "echo %LOCALAPPDATA%" 2>/dev/null | tr -d '\r')")
            ln -s "$localappdata/nvim" "$HOME/.config/nvim"
        fi
    fi
fi

# ╰───────────────────────────────────────────────── neovim ─╯


# ╭─ sfsu ───────────────────────────────────────────────────╮

if [[ -x "$(command -v sfsu)" ]]; then
    source <(sfsu.exe hook --shell bash)
fi

# ╰─────────────────────────────────────────────────── sfsu ─╯


# ╭─ starship ───────────────────────────────────────────────╮

if [[ -x "$(command -v starship)" ]]; then
    if ((is_wsl)); then
        userprofile=$(wslpath "$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')")
        export STARSHIP_CONFIG="$userprofile/.config/starship/starship.toml"
    else
        export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
    fi

    eval "$(starship init bash)"
fi

# ╰─────────────────────────────────────────────── starship ─╯


# ╭─ yazi ───────────────────────────────────────────────────╮

if [[ -x "$(command -v yazi)" ]]; then
    if ((is_wsl)); then
        if [[ ! -d "$HOME/.config/yazi" ]]; then
            appdata=$(wslpath "$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')")
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



# ╭───────╮
# │ Conda │
# ╰───────╯

if [[ -x "$(command -v mamba)" ]]; then
    if ((is_windows)); then
        export MAMBA_EXE="$HOME/scoop/apps/mambaforge/current/Library/bin/mamba.exe"
        if [[ -f "$MAMBA_EXE" ]]; then
            export MAMBA_EXE="$MAMBA_EXE"
            export MAMBA_ROOT_PREFIX="$HOME/scoop/persist/mambaforge"
            eval "$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"
        fi
    elif ((is_linux)); then
        if [[ -f "$HOME/mambaforge/bin/conda" ]]; then
            __conda_setup=$("$HOME/mambaforge/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)
            if [[ $? = 0 ]]; then
                eval "$__conda_setup"
            else
                if [[ -f "$HOME/mambaforge/etc/profile.d/conda.sh" ]]; then
                    . "$HOME/mambaforge/etc/profile.d/conda.sh"
                else
                    export PATH="$HOME/mambaforge/bin:$PATH"
                fi
            fi
            unset __conda_setup

            if ((is_wsl)); then
                if [[ ! -f "$HOME/.condarc" ]]; then
                    userprofile=$(wslpath "$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')")
                    ln -s "$userprofile/.condarc" "$HOME/.condarc"
                fi
            fi
        fi
    fi
fi
