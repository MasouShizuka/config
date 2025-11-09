REM https://github.com/jesseduffield/lazygit/issues/1453#issuecomment-3457250276

@echo off

set "old=%~2"
set "new=%~5"
set "target=%~1"
set "old=%old:\=/%"
set "new=%new:\=/%"

git --no-pager diff --no-index --no-ext-diff "%old%" "%new%"^
 | sed -e "s|%old%|%target%|g" -e "s|%new%|%target%|g"^
 | delta --paging=never --width=%LAZYGIT_COLUMNS%
