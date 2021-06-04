# Use TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

### Oauth Client Details ###
############################
$apiBaseUrl = "https://auth.domainname.com"
$clientId = 'client-id'
$clientSecret = 'client-secret'
$scope = "openid+scopeinfo"
$redirectUri = "http://localhost"
$basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($clientId, $clientSecret -join ":")))

Function Show-OAuthWindow {
    [CmdletBinding()]
    param (
        [System.Uri]
        $Url
    
    )
    Add-Type -AssemblyName System.Windows.Forms
 
    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=440;Height=640}
    $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=420;Height=600;Url=($Url) }
    $DocComp  = {
            $Global:uri = $web.Url.AbsoluteUri
            if ($Global:Uri -match "error=[^&]*|code=[^&]*") {
                $form.Close() 
            }
    }
    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($DocComp)
    $form.Controls.Add($web)
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() | Out-Null
    }


### Call Initial Authorization API ###
######################################
	
$authURI = $apiBaseUrl
$authURI += "/oauth/authorize?scope=$scope&response_type=code&redirect_uri=$redirectUri&client_id=$clientId"

Write-Host "Browser: Navigating to $authURI"
Show-OAuthWindow -Url $authURI

Write-Host "Browser: Returned $($Global:Uri)"

$url = $Global:Uri


### Parse Returned URL Parameters ### 
#####################################
if ($url -is [uri]) {
    $url = $url.ToString()
}

if ($url.IndexOf('?') -ge 0) {
    $query = ($url -split '\?')[1]    
    $query = $query.Split('#')[0]

    # detect variable names and their values in the query string
    foreach ($q in ($query -split '&')) {
        $kv = $($q + '=') -split '='
        $varName  = [uri]::UnescapeDataString($kv[0]).Trim()
        $varValue = [uri]::UnescapeDataString($kv[1])
        New-Variable -Name $varname -Value $varValue -Force
    }
}
else {
    Write-Warning "No query string found as part of the given URL"
}

if(!$code){
    Write-Error "Failed to get Auth Code"
    Exit 0
}

Write-Host "Retrieved Auth Code: $code"
$authCode = $code


### Call Access Token ###
#########################

$Body = @{"grant_type" = "authorization_code"; "scope" = $scope; "client_id" = "$clientId"; "code" = $authCode; "redirect_uri" = $redirectURI }
$tokenRequest = Invoke-RestMethod -Method Post -ContentType application/x-www-form-urlencoded -Uri "$apiBaseUrl/oauth/token" -Body $Body 

$AccessToken = $tokenRequest.access_token
Write-Host "Retrieved Access Token:" $AccessToken

### Call Refresh Token ###
##########################

# TODO
