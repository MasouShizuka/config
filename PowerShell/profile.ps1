If (Test-Path "$HOME/miniconda3/Scripts/conda.exe") {
    (& "$HOME/miniconda3/Scripts/conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression 2>$null
}
