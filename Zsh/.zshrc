# 激活 oh-my-posh 的主题 negligible
eval "$(~/Documents/PowerShell/Modules/oh-my-posh/oh-my-posh.exe --init --shell zsh --config ~/Documents/PowerShell/Modules/oh-my-posh/themes/negligible.omp.json)"

alias ll="ls -al --color -h --time-style=long-iso"

# 命令补全
autoload -U compinit && compinit

export LC_ALL=en_US.UTF-8
export LANG=en_US.utf8
export LC_CTYPE=en_US.utf8

# 命令行别名的自动补全
setopt completealiases
# 历史文件相关设置
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

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
