Function Get-DatabaseList {

    <#
    .SYNOPSIS
        Retrieves Databases from a list of SQL Servers. 
    .Description
        Retrieves Databases from a list of SQL Servers provided as an Array.
        It will return a list of database objects that can be assigned to a
        variable, or piped to a GridView/Export cmdlet. This will use the credentials
        of the user running the function to access the databases. 
    .PARAMETER ServerList
        The list of servers to query. This should be provided as an Array. e.g. @("Server1","Server2")
    .INPUTS
        None. You cannot pipe objects to Get-ClusterDBs.
    .NOTES
        Tags: AvailabilityGroup, SQlCluster, HA
        Author: DaneAlex
        License: MIT https://opensource.org/licenses/MIT
    .EXAMPLE
        PS C:\> Get-DatabaseList -ServerList @("Server1", "Server2")
        Gets the list of databases that are on Server1 and Server2 default SQL instances. 
    .EXAMPLE
        PS C:\> Get-DatabaseList -ServerList @("Server1", "Server2") | Out-GridView -Passthru 
        Gets the list of databases that are on Server1 and Server2 default SQL instances to a Grid View. 
    #>

	[CmdletBinding()]
	Param( 
		[Parameter(Position = 0, Mandatory = $true)]
        [Array]
        $ServerList
	) 

    $dbs = $null

    foreach($server in $ServerList){
        Write-Host "Getting dbs from $server"
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
        $s = New-Object ('Microsoft.Sqlserver.management.Smo.Server') $server
        $dbs += $s.Databases
    }

    return $dbs | Select Name, Parent, DataSpaceUsage


}
