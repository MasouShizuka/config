# ╭───────╮
# │ Alias │
# ╰───────╯

Set-Alias ll ls

Set-Alias lg lazygit

Set-Alias vi nvim
Set-Alias vim nvim



# ╭──────────────────────╮
# │ Environment Variable │
# ╰──────────────────────╯

$env:EDITOR="nvim"
$env:GIT_EDITOR="nvim"



# ╭──────────╮
# │ Function │
# ╰──────────╯

function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}



# ╭────────────╮
# │ keybinding │
# ╰────────────╯

Set-PSReadLineKeyHandler -Chord Ctrl+u -Function BackwardDeleteLine

Set-PSReadLineKeyHandler -Chord Shift+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Shift+RightArrow -Function ForwardWord

Set-PSReadlineKeyHandler -Chord UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Chord DownArrow -Function HistorySearchForward

Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete



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



# ╭───────────────────╮
# │ Command Line Tool │
# ╰───────────────────╯

# ╭─ fzf ────────────────────────────────────────────────────╮

$env:FZF_COMPLETION_TRIGGER="\\"
$env:FZF_DEFAULT_OPTS="
    --height=80%
    --layout=reverse
    --border=rounded
    --cycle
    --scroll-off=5
    --info=inline
    --preview='bat --number --color always --theme ansi --line-range :500 {}'
    --preview-border=rounded
    --bind=ctrl-i:accept
"

# # One Dark
# $env:FZF_DEFAULT_OPTS="$env:FZF_DEFAULT_OPTS
#     --color=dark
#     --color=fg:-1,bg:-1,hl:#c678dd,fg+:#abb2bf,bg+:#282c34,hl+:#c678dd
#     --color=info:#98c379,prompt:#61afef,pointer:#e06c75,marker:#e5c07b,spinner:#61afef,header:#61afef"
# Tokyo Night Moon
# https://github.com/folke/tokyonight.nvim/blob/main/extras/fzf/tokyonight_moon.sh
$env:FZF_DEFAULT_OPTS="$env:FZF_DEFAULT_OPTS
    --color=border:#589ed7
    --color=fg:#c8d3f5
    --color=gutter:#1e2030
    --color=header:#ff966c
    --color=hl+:#65bcff
    --color=hl:#65bcff
    --color=info:#545c7e
    --color=marker:#ff007c
    --color=pointer:#ff007c
    --color=prompt:#65bcff
    --color=query:#c8d3f5:regular
    --color=scrollbar:#589ed7
    --color=separator:#ff966c
    --color=spinner:#ff007c
"

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

$MAMBA_EXE="$HOME/scoop/apps/mambaforge/current/Library/bin/mamba.exe"
if (Test-Path "$MAMBA_EXE") {
    $Env:MAMBA_ROOT_PREFIX="$HOME/scoop/persist/mambaforge"
    $Env:MAMBA_EXE="$MAMBA_EXE"
    (& $Env:MAMBA_EXE 'shell' 'hook' -s 'powershell' -r $Env:MAMBA_ROOT_PREFIX) | Out-String | Invoke-Expression
}
