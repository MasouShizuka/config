#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "$HOME/miniconda3/Scripts/conda.exe") {
    (& "$HOME/miniconda3/Scripts/conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression 2>$null
}
#endregion
