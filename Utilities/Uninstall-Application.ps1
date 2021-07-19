$appToRemove = "Java"

$KeysFound = @()
#Search 32 bit registry entries
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" -Recurse | 
Where Name -like '*{*' | foreach {
    if($_.GetValue("DisplayName") -like "$appToRemove*"){
        Write-Host "$appToRemove 32-bit install found."
        $KeysFound += $_
    }
}

#Search 64 bit registry entries
Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" -Recurse | 
Where Name -like '*{*' | foreach {
    if($_.GetValue("DisplayName") -like "$appToRemove*"){
        Write-Host "$appToRemove 64-bit install found."
        $KeysFound += $_
    }
}

if($KeysFound.Count -eq 0){
    Write-Host "No $appToRemove installation detected. Exiting."
    Exit 3
}

foreach($app in $KeysFound){
    
    #Check if the uninstallstring key value has anything present
    if($app.GetValue("UninstallString") -ne $null){
        
        #add the uninstall arguments 
        $uninstallArguments = $app.GetValue("UninstallString").Replace("MsiExec.exe", "") + " /qn"

        Write-Host "Running command 'MsiExec.exe $uninstallArguments' to remove $($app.GetValue("DisplayName")) version $($app.GetValue("DisplayVersion"))"
        
        #try uninstall or catch the error
        try{
            Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "$uninstallArguments" -Wait
            Write-Host "Uninstall succeeded."
        }catch{
            Write-Host "Failed to uninstall."
            Exit 4
        }

    }
}
