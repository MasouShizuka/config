########
# 主题 #
########

eval "$(oh-my-posh init zsh --config ~/AppData/Local/Programs/oh-my-posh/themes/negligible.omp.json)"



#########
# Alias #
#########

alias ll="ls -al --color -h --time-style=long-iso"



############
# 环境变量 #
############

export LC_ALL=en_US.UTF-8
export LANG=en_US.utf8
export LC_CTYPE=en_US.utf8



########
# 设置 #
########

# 命令补全
autoload -U compinit && compinit
# 命令行别名的自动补全
setopt completealiases

# 历史文件
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# 设置执行命令后立即添加到历史
setopt INC_APPEND_HISTORY
# 历史去重
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

# 自动补全大小写不敏感
zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=*" "l:|=* r:|=*"
# 启动使用方向键控制自动补全
zstyle ":completion:*" menu select
# 刷新自动补全
zstyle ":completion:*" rehash true



########
# 插件 #
########

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh



#########
# conda #
#########

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# eval "$('/c/Users/MasouShizuka/miniconda3/Scripts/conda.exe' 'shell.zsh' 'hook')"
. /c/Users/MasouShizuka/miniconda3/etc/profile.d/conda_fixed.sh
# <<< conda initialize <<<
