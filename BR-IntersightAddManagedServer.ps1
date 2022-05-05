Param
(
[Parameter(Mandatory)][string]$serverName,
[Parameter(Mandatory)][int]$serverPlatform,
[Parameter(Mandatory)][string]$username,
[Parameter(Mandatory)][string]$credentialDesc
)

try {
    $managedServer = Get-VBRServer -Name $serverName
    Write-Output "managedServer - $managedServer"
    if ($managedServer -EQ $null) {
        $cred = Get-VBRCredentials | Where-Object {$_.Description -eq "$credentialDesc" -and $_.Name -eq "$username"}
        if ($cred -ne $null) {
            Switch ($serverPlatform) {
                0 {
                    Write-Output "Adding windows host"
                    Add-VBRWinServer -Name $serverName -Credentials $cred
                    }
                1 {        
                    Write-Output "Adding linux host"
                    Add-VBRLinux -Name $serverName -Credentials $cred
                    }
            }
        }
        else {
            Write-Output "Credentials not found!"
            exit 1
        }
    }
    else {
        Write-Output "Managed server already exists"
        exit 0
    }
    exit 0
}
catch { 
    Write-Output "Exception in add managed server" 
    exit 1 
}