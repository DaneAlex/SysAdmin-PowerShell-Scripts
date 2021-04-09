### LOAD NECESSARY MODULES ###
##############################

Install-Module SQL-SMO
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement')

### SET PATH PARAMETERS ###
###########################

$defaultSystemDatabasePath = "E:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA"
$desiredSystemDatabasePath = "F:\Databases"
$desiredSystemDatabaseLogPath = "L:\Logs"

### BEGIN MOVING DATABASES ###
##############################

$smo = New-SMO -ServerName localhost -Verbose

# Alter Model and MSDB File Paths in SQL 

$('model','MSDB') |
    ForEach-Object {$Db = $smo.databases[$PSItem]
        foreach ($fg in $Db.FileGroups) 
        {foreach ($fl in $fg.Files) {$fl.FileName = $fl.FileName.Replace($defaultSystemDatabasePath, $desiredSystemDatabasePath)}}
        foreach ($fl in $Db.LogFiles) {$fl.FileName = $fl.FileName.Replace($defaultSystemDatabasePath, $desiredSystemDatabaseLogPath)}
        $smo.databases[$PSItem].Alter()
    }

Stop-Service -Name MSSQLSERVER -Force -Verbose

# Physically Move the Files To The New Directory

$('mast', 'model','MSDB') | ForEach-Object {Move-Item -Path $($defaultSystemDatabasePath + '\' + $PSItem+'*.mdf') -Destination $($desiredSystemDatabasePath + "\") -Verbose}
$('mast', 'model','MSDB') | ForEach-Object {Move-Item -Path $($defaultSystemDatabasePath + '\' + $PSItem+'*.ldf') -Destination $($desiredSystemDatabaseLogPath + "\") -Verbose}

# Update Startup Parameters for Master DB and Log

$wmisvc = $(New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer 'localhost').Services | where {$_.name -eq "MSSQLSERVER"}
$wmisvc.StartupParameters= "-d$desiredSystemDatabasePath\master.mdf;-eF:\SystemDB\ERRORLOG;-l$desiredSystemDatabaseLogPath\mastlog.ldf"
$wmisvc.Alter()

Start-Service -Name MSSQLSERVER,SQLSERVERAGENT -Verbose

