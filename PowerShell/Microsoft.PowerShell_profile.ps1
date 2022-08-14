Import-Module posh-git
Import-Module PSReadLine

########
# 主题 #
########

oh-my-posh init pwsh --config "~/AppData/Local/Programs/oh-my-posh/themes/negligible.omp.json" | Invoke-Expression



#########
# Alias #
#########

Set-Alias ll ls



############
# 环境变量 #
############

$history="$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\$($host.Name)_history.txt"
$runningInVsCode = $env:TERM_PROGRAM -eq "vscode"



####################
# PSReadLineOption #
####################

Set-PSReadLineOption –HistoryNoDuplicates:$True
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History
if (-not $runningInVsCode) {
    Set-PSReadLineOption -PredictionViewStyle ListView
}

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo



##############
# 自定义函数 #
##############

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
    C:/msys64/msys2_shell.cmd -defterm -here -mingw64 -no-start -use-full-path -shell zsh
}
