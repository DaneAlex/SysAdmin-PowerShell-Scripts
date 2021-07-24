<#
  .SYNOPSIS
  Get Subscription Owner and Contributor Users and their MFA Status

  .DESCRIPTION
  The script will run against an Array of Subscription IDs, retrieve
  all users with "Owner" or "Contributor" level access to resources using the 
  Azure AzModule. It will then go through each of those users and get their MFA status 
  using the Microsoft Online Module. Assists with CIS Azure 1.1 from the Microsoft
  Azure Foundations Benchmark 1.3.0

  If your user has MFA, you will be asked to sign in for the AzModule and again for MSOnline.

  .INPUTS
  None. You cannot pipe objects to Get-AzOwnerContributorMFA.ps1.

  .OUTPUTS
  PrivilegedUserMFAStatus.csv

  .EXAMPLE
  PS> .\Get-AzOwnerContributorMFA.ps1 
#>

Function Get-SubscriptionOwnerContributors{
	[CmdletBinding()]
	Param( 
		[Parameter(Position = 0, Mandatory = $true)]
        [Array]
        $SubscriptionIds
	) 

    $OwnerContributorList = @()
    foreach($subscriptionId in $SubscriptionIds){
        $OwnerContributorRoles = Get-AzRoleAssignment -Scope "/subscriptions/$subscriptionId" | Where-Object {$_.RoleDefinitionName -like "Owner" -or $_.RoleDefinitionName -like "Contributor"}
        foreach($role in $OwnerContributorRoles){
            if(-not ($OwnerContributorList -contains $role.SignInName)){
                $OwnerContributorList += $role.SignInName
            }
        }
    }
    return $OwnerContributorList
}

Function Get-MFAStatusForUsers{
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [Array]
        $UserList
    )

    $MFAusers = @()
    foreach($user in $UserList){
        if($null -eq $user){
            $user = Get-MsolUser -UserPrincipalName $user | Select-Object DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationMethods.IsDefault -eq $true) {($_.StrongAuthenticationMethods | Where IsDefault -eq $True).MethodType} else { "Disabled"}}}
            $MFAusers += $user
        }
    }
    return $MFAusers
}

#### BEGIN SCRIPT EXECUTION ####

## Global Variables
$defaultPath = [Environment]::GetFolderPath("Desktop")

$subscriptionIds = @(
    "########-####-####-####-############", #Subscription 1 from Azure
    "########-####-####-####-############" #Subscriptoin 2
)

# Prompt User for location and allow to use default
if (!($exportPath = Read-Host "Where would you like to export the generated report? Press Enter to Keep Default Path: [$defaultPath]")) { $exportPath = $defaultPath }

Write-Host "Connecting to Azure Active Directory"
Connect-AzAccount

Write-Host "Getting Subscription Owners and Contributors for the following subscriptions: $([string]::Join(",", $subscriptionIds))"
$OwnerContributors = Get-SubscriptionOwnerContributors -SubscriptionIds $subscriptionIds

Write-Host "Connecting to Microsoft Online"
Connect-MsolService

Write-Host "Getting MFA Status for the Subscription Owners and Contributors"
$MFAusers = Get-MFAStatusForUsers -UserList $OwnerContributors

Write-Host "Outputting CSV"
$MFAusers | Export-CSV "$exportPath\PrivilegedUserMFAStatus.csv" -NoTypeInformation
