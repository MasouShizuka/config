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
export LANG=en_US.utf8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.utf8



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

# 历史文件
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# 历史去重
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
# 设置执行命令后立即添加到历史
setopt INC_APPEND_HISTORY

# 自动补全大小写不敏感
zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=*" "l:|=* r:|=*"
# 启动使用方向键控制自动补全
zstyle ":completion:*" menu select
# 刷新自动补全
zstyle ":completion:*" rehash true



#########
# Theme #
#########

eval "$(oh-my-posh init zsh --config ~/AppData/Local/Programs/oh-my-posh/themes/negligible.omp.json)"



##########
# Plugin #
##########

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh



#########
# Conda #
#########

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# if [ -f '/c/Users/MasouShizuka/miniconda3/Scripts/conda.exe' ]; then
#     eval "$('/c/Users/MasouShizuka/miniconda3/Scripts/conda.exe' 'shell.zsh' 'hook')"
# fi
. /c/Users/MasouShizuka/miniconda3/etc/profile.d/conda_fixed.sh
# <<< conda initialize <<<
