# install scoop
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# install git and clone config repo
scoop install git
git config --global credential.helper manager
git config --global core.editor nvim

git clone https://github.com/MasouShizuka/config.git --depth 1

# add buckets
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add versions

# install tools
scoop install aria2
scoop config aria2-warning-enabled false
scoop install dos2unix
scoop install sfsu

# install Microsoft Visual C++ Redistributables
scoop install vcredist
scoop uninstall vcredist2005 vcredist2008 vcredist2010 vcredist2012 vcredist2013 vcredist --purge

# install fonts
scoop install Maple-Mono-NF-CN
scoop install SarasaGothic-SC

# install msys2
scoop install msys2
# change home in msys2 to USERPROFILE in windows
$nsswitch_path="$env:USERPROFILE\scoop\apps\msys2\current\etc\nsswitch.conf"
(Get-Content "$nsswitch_path") -replace "db_home: cygwin desc", "db_home: windows" | Set-Content "$nsswitch_path"
# add ucrt64/bin and usr/bin to PATH of User's environment variable
$old_path=[System.Environment]::GetEnvironmentVariable("Path", "User")
$new_path="$env:USERPROFILE\scoop\apps\msys2\current\ucrt64\bin;$env:USERPROFILE\scoop\apps\msys2\current\usr\bin;$old_path"
[System.Environment]::SetEnvironmentVariable("Path", $new_path, "User")
# setup msys2
msys2
