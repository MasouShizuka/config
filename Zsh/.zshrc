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



################
# Key bindings #
################

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# 上下键切换前缀为当前命令开头到光标位置的历史命令
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# Shift+左右键移动到上/下一个单词
key[Shift-Left]="${terminfo[kLFT]}"
key[Shift-Right]="${terminfo[kRIT]}"
[[ -n "${key[Shift-Left]}"  ]] && bindkey -- "${key[Shift-Left]}"  backward-word
[[ -n "${key[Shift-Right]}" ]] && bindkey -- "${key[Shift-Right]}" forward-word



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
setopt INC_APPEND_HISTORY_TIME   # Write to the history file immediately, not when the shell exits.
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
    #     sed -i "\$!{/${LASTHIST_SED}/d;}" "$HISTFILE"
    # fi

    # 添加命令到历史文件前删除相同的历史命令，并手动追加到历史文件中，防止文件乱码
    if [[ -n ${LASTHIST//[[:space:]]/} ]] ; then
        LASTHIST_TRIM=${LASTHIST%%$'\n'}
        LASTHIST_SED="$(<<< $LASTHIST_TRIM sed -e 's`[][\\/.*^$]`\\&`g')"
        sed -i "{/${LASTHIST_SED}/d;}" "$HISTFILE"
        echo "$LASTHIST_TRIM" >> "$HISTFILE"
    fi
}

zshaddhistory() {
    LASTHIST=$1

    # Return value 2: "... the history line will be saved on the internal
    # history list, but not written to the history file".
    return 2
}

# 退出后删除最后一条以外的重复命令
zshexit() {
    if [[ -n ${LASTHIST//[[:space:]]/} ]] ; then
        tac "$HISTFILE" | awk '!a[$0]++' | tac > ~/tmpfile
        # tac "$HISTFILE" | awk -F ';' '!a[$2]++' | tac > ~/tmpfile
        mv ~/tmpfile "$HISTFILE"
    fi
}

# 自动补全大小写不敏感
zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=*" "l:|=* r:|=*"
# 启动使用方向键控制自动补全
zstyle ":completion:*" menu select
# 刷新自动补全
zstyle ":completion:*" rehash true



#########
# Theme #
#########

eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/negligible.omp.json)"



##########
# Plugin #
##########

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
