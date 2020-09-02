# Function to prompt windows and allow user to select FileName.
Function Get-FileName($initialDirectory,$FileFilter,$Title) {   
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
    Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = $FileFilter
    $OpenFileDialog.title = $Title
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}  #end function Get-FileName

Clear-Variable ("Out", "Text", "Count") -ErrorAction SilentlyContinue

#Write FileName path in variabel FileName
$FileName = Get-FileName -FileFilter "VTT files (*.vtt)| *.vtt|All files (*.*)| *.*"

#Read VTT file and write in Text variable
$Text = Get-Content $FileName -Encoding utf8

#Add count
$Count = 1

#Read each line in variable text to replace charachters
$Text|foreach{
    if ($_ -match '^(?<Group1>\d{2}:\d{2}:\d{2})\.(?<Group2>\d{3} --> \d{2}:\d{2}:\d{2})\.(?<Group3>\d{3})$'){
        $Out += [string]$Count + "`n";$Out += $Matches.Group1 + "," + $Matches.Group2 + "," + $Matches.Group3 + "`n";$Count++
        } elseif (!$_){} elseif ($_ -match '^(........-....-....-....-............)$'){
        } elseif ($($_).StartsWith("NOTE Confidence: ") -or $($_).StartsWith("NOTE duration:`"") -or $($_).StartsWith("NOTE language:") -or $($_).StartsWith("WEBVTT")) {
        } else {
        $Out += $_ + "`n"
        }
    }

#Write replaced text in SRT file using the same folder and name
$Out|Out-File -FilePath $([System.IO.Path]::GetDirectoryName($FileName)+'\'+[System.IO.Path]::GetFileNameWithoutExtension($FileName) + ".srt") -Encoding utf8
Write-Host "The file " -NoNewline -ForegroundColor Green
Write-Host `"$([System.IO.Path]::GetFileNameWithoutExtension($FileName) + ".srt")`" -NoNewline -ForegroundColor Red
Write-Host " was saved on " -NoNewline -ForegroundColor Green
Write-Host `"$([System.IO.Path]::GetDirectoryName($FileName))`" -NoNewline -ForegroundColor Red
Write-Host " directory" -ForegroundColor Green
pause
