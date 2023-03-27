Import-Module posh-git
Import-Module PSReadLine

#########
# Alias #
#########

Set-Alias ll ls

Set-Alias vi nvim
Set-Alias vim nvim



########################
# Environment Variable #
########################

$history=(Get-PSReadlineOption).HistorySavePath
$is_vscode = $env:TERM_PROGRAM -eq "vscode"



############
# Function #
############

# 打开目录
function open($path=".") {
    Invoke-Item $Path
}

# 显示程序路径
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# 打开 Zsh
function zsh() {
    C:/msys64/msys2_shell.cmd -defterm -here -no-start -shell zsh -ucrt64 -use-full-path
}



####################
# PSReadLineOption #
####################

Set-PSReadLineOption -HistoryNoDuplicates:$False
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History
if (-not $is_vscode) {
    Set-PSReadLineOption -PredictionViewStyle ListView
} else {
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineKeyHandler -Chord "Shift+RightArrow" -Function ForwardWord
}

# 添加命令到历史文件前删除相同的历史命令
$startup=(Get-Content $history).Count
Set-PSReadLineOption -AddToHistoryHandler {
    Param([string]$line)

    if ($script:startup -gt 0) {
        $script:startup=$script:startup - 1
    } else {
        $content=Get-Content $history
        $content | Where-Object { $_ -ne ($line) } | Set-Content $history
    }

    return $True
}

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo



#########
# Theme #
#########

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/negligible.omp.json" | Invoke-Expression
