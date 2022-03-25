Import-Module oh-my-posh
Import-Module posh-git

# 环境变量

$history="$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\$($host.Name)_history.txt"
$runningInVsCode = $env:TERM_PROGRAM -eq "vscode"


# alias

Set-Alias ll ls
Set-Alias zsh "C:\Program Files\Git\usr\bin\zsh.exe"


# 主题

Set-PoshPrompt negligible


# PSReadLineOption 设置

Set-PSReadLineOption –HistoryNoDuplicates:$True
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History
if (-not $runningInVsCode) {
    Set-PSReadLineOption -PredictionViewStyle ListView
}


# PSReadLineKeyHandler 设置

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo


# 自定义函数

# 打开目录
function open($path=".") {
    Invoke-Item $Path
}
# 显示程序路径
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}


# 启动执行命令

if (-not $runningInVsCode) {
    zsh
}

