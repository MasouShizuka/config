Import-Module PSReadLine

# ╭───────╮
# │ Alias │
# ╰───────╯

Set-Alias ll ls

Set-Alias lg lazygit

Set-Alias vi nvim
Set-Alias vim nvim

function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}



# ╭──────────────────────╮
# │ Environment Variable │
# ╰──────────────────────╯

$env:TERM_PROGRAM="WindowsTerminal"



# ╭─────────╮
# │ Setting │
# ╰─────────╯

$history=(Get-PSReadlineOption).HistorySavePath
$WarningPreference="SilentlyContinue"

Set-PSReadLineOption -HistoryNoDuplicates:$false
Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView

# 添加命令到历史文件前删除相同的历史命令
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    $line_slash=$line.replace("\", "/")
    $line_trim=$line_slash.Trim()

    $content=Get-Content $history
    $content | Where-Object { $_ -ne ($line_trim) } | Set-Content $history
    Add-Content -Path $history -Value $line_trim

    return "MemoryOnly"
}

Set-PSReadLineKeyHandler -Chord Ctrl+u -Function BackwardDeleteLine
Set-PSReadLineKeyHandler -Chord Shift+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Shift+RightArrow -Function ForwardWord
Set-PSReadlineKeyHandler -Chord UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Chord DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete



# ╭───────────────────╮
# │ Command Line Tool │
# ╰───────────────────╯

# ╭─ fzf ────────────────────────────────────────────────────╮

$env:FZF_DEFAULT_OPTS="\\"
$env:FZF_DEFAULT_OPTS="--bind=ctrl-i:accept --cycle --scroll-off=5 --height=80% --layout=reverse --border --info=inline --preview='bat --theme=TwoDark --color=always --style=numbers --line-range=:500 {}'"

# One Dark
$env:FZF_DEFAULT_OPTS="$env:FZF_DEFAULT_OPTS
    --color=dark
    --color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
    --color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef"

# ╰──────────────────────────────────────────────────── fzf ─╯


# ╭─ sfsu ───────────────────────────────────────────────────╮

Invoke-Expression (&sfsu hook)

# ╰─────────────────────────────────────────────────── sfsu ─╯


# ╭─ starship ───────────────────────────────────────────────╮

$env:STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
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

# ╰─────────────────────────────────────────────── starship ─╯


# ╭─ yazi ───────────────────────────────────────────────────╮

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

# ╰─────────────────────────────────────────────────── yazi ─╯



# ╭───────╮
# │ Conda │
# ╰───────╯

if (Test-Path "$HOME/scoop/apps/mambaforge/current/Scripts/conda.exe") {
    (& "$HOME/scoop/apps/mambaforge/current/Scripts/conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression 2>$null
}
