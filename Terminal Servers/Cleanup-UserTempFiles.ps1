##############################################################################
#.SYNOPSIS
# Clean Temp File folders for all users. 
#
#.DESCRIPTION
# This script will run against user tmeporary and temporary internet files
# and attempt to remove any potential files. 
#
# If you have web applications that may rely on on temp file folders, you
# may want to do additional testing or research to validate this won't have a
# negative impact on your user's experience. 
#
#.EXAMPLE
# If the server blocks this script, try running the below first:
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
#
# .\Cleanup-UserTempFiles.ps1
##############################################################################


Set-Location "C:\Users"
Remove-Item ".\*\Appdata\Local\Temp\*" -recurse -force
Remove-Item ".\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content\*" -recurse -force
Remove-Item ".\*\AppData\Local\Microsoft\Windows\INetCache\*" -recurse -force

$chromeInstalled = (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo

if ($chromeInstalled.FileName -eq $null) {
  Remove-Item ".\*\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -recurse -force
}
