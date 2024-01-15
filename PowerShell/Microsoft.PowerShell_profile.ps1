Import-Module posh-git
Import-Module PSReadLine

# ╭───────╮
# │ Alias │
# ╰───────╯

Set-Alias ll ls

Set-Alias vi nvim
Set-Alias vim nvim



# ╭──────────────────────╮
# │ Environment Variable │
# ╰──────────────────────╯

$history=(Get-PSReadlineOption).HistorySavePath
$is_vscode=$env:TERM_PROGRAM -eq "vscode"
$WarningPreference="SilentlyContinue"



# ╭──────────╮
# │ Function │
# ╰──────────╯

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
    C:/msys64/msys2_shell.cmd -ucrt64 -defterm -here -use-full-path -no-start -shell zsh
}



# ╭──────────────────╮
# │ PSReadLineOption │
# ╰──────────────────╯

Set-PSReadLineOption -HistoryNoDuplicates:$false
Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView

# 添加命令到历史文件前删除相同的历史命令
$global:is_startup=$true
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    $line_slash=$line.replace("\", "/")
    $line_trim=$line_slash.Trim()

    # powershell 启动时会检查每条历史记录，跳过启动时的检查
    $last_line=Get-Content $history -Tail 1
    if ($global:is_startup) {
        if ($line -eq $last_line) {
            $global:is_startup=$false
        }
    } else {
        $content=Get-Content $history
        $content | Where-Object { $_ -ne ($line_trim) } | Set-Content $history
        Add-Content -Path $history -Value $line_trim
    }

    return "MemoryOnly"
}



# ╭──────────────────────╮
# │ PSReadLineKeyHandler │
# ╰──────────────────────╯

Set-PSReadLineKeyHandler -Chord "Shift+RightArrow" -Function ForwardWord
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo



# ╭───────╮
# │ Theme │
# ╰───────╯

$ENV:STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
Invoke-Expression (&starship init powershell)

# OSC 7 on Windows with powershell (with starship)
if ($env:TERM_PROGRAM -eq "WezTerm") {
    $prompt=""
    function Invoke-Starship-PreCommand {
        $current_location=$executionContext.SessionState.Path.CurrentLocation
        if ($current_location.Provider.Name -eq "FileSystem") {
            $ansi_escape=[char]27
            $provider_path=$current_location.ProviderPath -replace "\\", "/"
            $prompt="$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}$ansi_escape\"
        }
        $host.ui.Write($prompt)
    }
}



# ╭───────╮
# │ Conda │
# ╰───────╯

if (Test-Path "$HOME/miniconda3/Scripts/conda.exe") {
    (& "$HOME/miniconda3/Scripts/conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression 2>$null
}
