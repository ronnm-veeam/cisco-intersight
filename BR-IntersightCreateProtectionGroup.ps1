Param
(
[Parameter(Mandatory)][string]$protectionGroupName,
[Parameter(Mandatory)][string]$protectionGroupDesc,
[Parameter(Mandatory)][string]$agentTarget,
[Parameter(Mandatory)][string]$userName,
[Parameter(Mandatory)][string]$userDesc
)

try {
    $cred = Get-VBRCredentials | Where-Object {$_.Description -eq "$userDesc" -and $_.Name -eq "$userName"}
    if ($cred -ne $null) {
        $customCredsArray = @()
        $icCreds = New-VBRIndividualComputerCustomCredentials -HostName $agentTarget -Credentials $cred
        $customCredsArray += $icCreds

        $protContainer = New-VBRIndividualComputerContainer -CustomCredentials $customCredsArray
 
        $protGroup = Add-VBRProtectionGroup -Name "$protectionGroupName" -Container $protContainer -Description "$protectionGroupDesc"

        $deploymentOpt = New-VBRProtectionGroupDeploymentOptions -InstallAgent -UpgradeAutomatically -RebootIfRequired

        Set-VBRProtectionGroup -ProtectionGroup $protGroup -DeploymentOptions $deploymentOpt

        Rescan-VBREntity -Entity $protGroup   
    }
    else {
        Write-Output "Credentials not found!"
        exit 1
    }
}
catch {
    Write-Output "Exception in add protection group"
    exit 1
}