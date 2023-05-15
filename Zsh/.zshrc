#########
# Alias #
#########

alias ll="ls -al --color -h --time-style=long-iso"

autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn

alias vi=nvim
alias vim=nvim



########################
# Environment Variable #
########################

export EDITOR=nvim

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export MSYS=winsymlinks:nativestrict



###########
# Setting #
###########

# 命令补全
autoload -Uz compinit && compinit

# 历史文件和大小
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# 历史设置
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
# setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
# setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
# setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

precmd() {
    # Write the last command if successful (or closed with signal 2), using
    # the history buffered by my_zshaddhistory().
    # if [[ ($? == 0 || $? == 130) && -n ${LASTHIST//[[:space:]]/} ]] ; then
    #     print -sr -- ${LASTHIST%%$'\n'}
    # fi

    # 添加命令到历史文件后删除之前相同的历史命令
    # if [[ -n ${LASTHIST//[[:space:]]/} ]] ; then
    #     LASTHIST_SED="$(<<< ${LASTHIST%%$'\n'} sed -e 's`[][\\/.*^$]`\\&`g')"
    #     sed -i "\$!{/^${LASTHIST_SED}$/d;}" "$HISTFILE"
    # fi

    # 添加命令到历史文件前删除相同的历史命令，并手动追加到历史文件中，防止文件乱码
    if [[ -n ${LASTHIST//[[:space:]]/} ]] ; then
        LASTHIST_SLASH=${LASTHIST//\\//}

        LASTHIST_TRIM=${LASTHIST_SLASH%%$'\n'}
        LASTHIST_TRIM="${LASTHIST_TRIM#"${LASTHIST_TRIM%%[![:space:]]*}"}"
        LASTHIST_TRIM="${LASTHIST_TRIM%"${LASTHIST_TRIM##*[![:space:]]}"}"

        LASTHIST_SED="$(<<< $LASTHIST_TRIM sed -e 's`[][\\/.*^$]`\\&`g')"
        sed -i "{/^${LASTHIST_SED}$/d;}" "$HISTFILE"

        echo "$LASTHIST_TRIM" >> "$HISTFILE"
    fi
}

zshaddhistory() {
    LASTHIST=$1

    # Return value 2: "... the history line will be saved on the internal
    # history list, but not written to the history file".
    return 2
}

# 退出后删除所有重复命令，并保留最后一条
# zshexit() {
#     if [[ -n ${LASTHIST//[[:space:]]/} ]] ; then
#         tac "$HISTFILE" | awk '!a[$0]++' | tac > ~/tmpfile
#         # tac "$HISTFILE" | awk -F ';' '!a[$2]++' | tac > ~/tmpfile
#         mv ~/tmpfile "$HISTFILE"
#     fi
# }

# 自动补全大小写不敏感
zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=*" "l:|=* r:|=*"
# 启动使用方向键控制自动补全
zstyle ":completion:*" menu select
# 刷新自动补全
zstyle ":completion:*" rehash true



#########
# Theme #
#########

export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
eval "$(starship init zsh)"



##################
# Plugin Manager #
##################

ZINIT_HOME="$HOME/.zinit/zinit.git"
[[ ! -d $ZINIT_HOME ]] && mkdir -p "$(dirname $ZINIT_HOME)"
[[ ! -d $ZINIT_HOME/.git ]] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit



##########
# Plugin #
##########

zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    blockf \
        zsh-users/zsh-completions \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions

function zvm_config() {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_VI_SURROUND_BINDKEY=s-prefix
}
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Shift+左右键移动到上/下一个单词
bindkey "${terminfo[kLFT]}" backward-word
bindkey "${terminfo[kRIT]}" forward-word

# 切换前缀为当前命令开头到光标位置的历史命令
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

function zvm_after_init() {
    bindkey "^[[A" up-line-or-beginning-search
    bindkey "^[[B" down-line-or-beginning-search
}

function zvm_after_lazy_keybindings() {
    zvm_bindkey vicmd "H" zle vi-first-non-blank
    zvm_bindkey vicmd "L" zle vi-end-of-line

    zvm_bindkey vicmd "j" zle down-line-or-beginning-search
    zvm_bindkey vicmd "k" zle up-line-or-beginning-search
    zvm_bindkey vicmd "^[[A" up-line-or-beginning-search
    zvm_bindkey vicmd "^[[B" down-line-or-beginning-search
}



#########
# Conda #
#########

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if [[ -f "$HOME/miniconda3/Scripts/conda" ]]; then
    # eval "$('$HOME/miniconda3/Scripts/conda.exe' 'shell.zsh' 'hook')"
    eval "$($HOME/miniconda3/Scripts/conda 'shell.zsh' 'hook' | sed -e 's/"$CONDA_EXE" $_CE_M $_CE_CONDA "$@"/"$CONDA_EXE" $_CE_M $_CE_CONDA "$@" | tr -d \x27\\r\x27/g')" 2>/dev/null
fi
# <<< conda initialize <<<
