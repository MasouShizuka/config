export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
eval "$(starship init bash)"

# PROMPT_COMMAND='history -a'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if [[ -f "$HOME/miniconda3/Scripts/conda.exe" ]]; then
    eval "$($HOME/miniconda3/Scripts/conda.exe 'shell.bash' 'hook')"
fi
# <<< conda initialize <<<
