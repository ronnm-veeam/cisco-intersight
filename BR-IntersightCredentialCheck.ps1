Param
(
[Parameter(Mandatory)][string]$username,
[Parameter(Mandatory)][string]$password,
[Parameter(Mandatory)][string]$credentialDesc
)

try {
    $cred = Get-VBRCredentials | Where-Object {$_.Description -eq "$credentialDesc" -and $_.Name -eq "$username"}
    if ($cred -EQ $null) {
        $cred = Add-VBRCredentials -User "$username" -Password "$password" -Description "$credentialDesc"
        if ($cred -EQ $null) { exit 1 }
    }
    exit 0
}
catch { exit 1 }
