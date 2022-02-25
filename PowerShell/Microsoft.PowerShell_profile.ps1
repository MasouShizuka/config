Import-Module oh-my-posh
Import-Module posh-git

$history="$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\$($host.Name)_history.txt"
$runningInVsCode = $env:TERM_PROGRAM -eq 'vscode'

Set-Alias ll ls

Set-PoshPrompt negligible

Set-PSReadLineOption –HistoryNoDuplicates:$True
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History
if (-not $runningInVsCode) {
    Set-PSReadLineOption -PredictionViewStyle ListView
}

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo

# 打开目录
function open($path='.') {
    Invoke-Item $Path
}
# 显示程序路径
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

