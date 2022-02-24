$Aria2Dir = "D:/Tools/Aria2"
$ConfigFile = "$Aria2Dir/aria2.conf"
$ConfigFileBackup = "$Aria2Dir/aria2_backup.conf"
$ExeFile = "$Aria2Dir/aria2c.exe"

$TrackersFile = "best_aria2.txt"
$DownloadLink = "https://trackerslist.com/$TrackersFile"

try {
    $Response = Invoke-WebRequest -Uri $DownloadLink -OutFile $Aria2Dir/$TrackersFile
    $StatusCode = $Response.StatusCode

    # $TrackersStream = (Get-Content $Aria2Dir/$TrackersFile -Raw).Replace("`n`n", ",").Insert(0, "bt-tracker=")
    $TrackersStream = (Get-Content $Aria2Dir/$TrackersFile -Raw).Insert(0, "bt-tracker=")
    # $TrackersStream = $TrackersStream.Substring(0, $TrackersStream.Length - 1)

    $ExcludeLineNum=(Select-String -Path $ConfigFileBackup -SimpleMatch "bt-tracker=").LineNumber
    $ConfigStream = Get-Content $ConfigFileBackup -Encoding UTF8
    $ConfigStream[$ExcludeLineNum-1]=$TrackersStream
    Set-Content -Path $ConfigFile -Value $ConfigStream -Encoding UTF8

    Remove-Item -Path $Aria2Dir/$TrackersFile
} catch {
    $StatusCode = $_.Exception.Response.StatusCode.value__
}

Start-Process -FilePath $ExeFile -WorkingDirectory $Aria2Dir -ArgumentList --conf-path=$ConfigFile -WindowStyle Hidden
