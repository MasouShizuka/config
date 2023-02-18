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

$history="$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\$($host.Name)_history.txt"
$runningInVsCode = $env:TERM_PROGRAM -eq "vscode"



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

Set-PSReadLineOption –HistoryNoDuplicates:$True
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History
if (-not $runningInVsCode) {
    Set-PSReadLineOption -PredictionViewStyle ListView
} else {
    Set-PSReadLineKeyHandler -Chord "Shift+RightArrow" -Function ForwardWord
}

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo



#########
# Theme #
#########

oh-my-posh init pwsh --config "~/AppData/Local/Programs/oh-my-posh/themes/negligible.omp.json" | Invoke-Expression
