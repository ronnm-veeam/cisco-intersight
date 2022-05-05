Param
(
[Parameter(Mandatory)][string]$serverName,
[Parameter(Mandatory)][int]$proxyType
)

try {
    $managedServer = Get-VBRServer -Name $serverName
    if ($managedServer -NE $null) {
        Switch ($proxyType) {
            0 {
                Write-Host "Adding VMWare proxy"
                Add-VBRViProxy -Server $serverName
            }
            default {
                Write-Host "Proxy type not supported!"
                exit 1
            }
        }
        exit 0 
    }
    else {
        Write-Output "Managed server not found!"
        exit 0
    }
}
catch {
    Write-Output "Exception in add proxy"
    exit 1
}