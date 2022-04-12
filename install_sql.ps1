# Veeam Backup & Replication Unattended Install
#
# Install SQL 2014 
#
# Based on scripts originally written by Timothy Dewin:
# http://blog.dewin.me/2013/12/1-click-veeam-install-on-windows-2012.html

param
(
[ValidateNotNullorEmpty()][string]$srvuser=$(throw "SrvUser is required, provide a user account for install."),
[ValidateNotNullorEmpty()][string]$srvdomain=$(throw "SrvDomain is mandatory, provide a domain for the user."),
[ValidateNotNullorEmpty()][string]$srvpasswd=$(throw "SrvPasswd is mandatory, provide a password for the user."),
[ValidateNotNullorEmpty()][string]$logdir=$(throw "LogDir is mandatory, provide a path for storing installation logs."),
[ValidateNotNullorEmpty()][string]$basepath=$(throw "BasePath is mandatory, provide a directory containing the install source files."),
[string]$installdir="C:\Program Files",
[string]$sqlinstancename="VEEAMSQL2016",
[string]$installdirsqlexpr = $installdir+"\Microsoft SQL Server",
[string]$installdirsqldata = $installdir+"\Microsoft SQL Server"
)

# Install .NET 3.5 as required for SQL
$ProgressPreference = "SilentlyContinue"
if (!(Get-WindowsFeature NET-Framework-Core).Installed) {
    Write-host "Installing .NET 3.5 required for SQL Install"
    Add-WindowsFeature NET-Framework-Core > $null
    } else {
    Write-Host ".NET 3.5 already installed, skipping"
}

$srvdomuser = $srvdomain+"\"+$srvuser
$sqlsetup = $basepath+"Redistr\x64\SqlExpress\2016SP2\SQLEXPR_x64_ENU.exe"

$sqltest = Get-Service | where { $_.ServiceName -eq "\'MSSQL $sqlinstancename\'"}
if ($sqltest.count -eq 0 ) {
    if (-not (Test-Path $sqlsetup))
    {
        Write-host 'Veeam SQL Express installer not found!'
        exit 1
    }
    $arguments="/q /Action=Install /HideConsole=1  /Features=SQL,Tools /InstanceName=$sqlinstancename /SQLSYSADMINACCOUNTS=$srvdomuser /SQLSVCACCOUNT=$srvdomuser /SQLSVCPASSWORD=$srvpasswd /TCPENABLED=1 /NPENABLED=1 /IAcceptSQLServerLicenseTerms=1 /UpdateEnabled=$false"
    Write-host "Installing $sqlsetup" *> $logdir"\install_sql.log"
    
    $securePassword = ConvertTo-SecureString -String $srvpasswd -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $srvdomuser, $securePassword
    
    Write-Host "Start-Process -FilePath $sqlsetup -arg $arguments -Wait -PassThru -LoadUserProfile" *>> $logdir"\install_sql.log"
    Start-Process -FilePath $sqlsetup -arg $arguments -Wait -PassThru -LoadUserProfile *>> $logdir"\install_sql.log"
    #Write-Host "Start-Process -FilePath $sqlsetup -arg $arguments -LoadUserProfile -passthru -Credential $cred | wait-process" *>> $logdir"\install_sql.log"
    #Start-Process -FilePath $sqlsetup -arg $arguments -LoadUserProfile -passthru -Credential $cred | wait-process *>> $logdir"\install_sql.log"
    
    Write-host "Installation completed $sqlsetup" *>> $logdir"\install_sql.log"
}
else
{
    write-host "$sqlinstancename is already installed, skipping" *>> $logdir"\install_sql.log"
}

$sqltest = Get-Service | where { $_.ServiceName -eq 'MSSQL $sqlinstancename'  }
if ($sqltest.count -gt 0 -and $sqltest[0].Status -ne 'running' )
{
    write-host "Couldn't find installed $sqlinstancename so might install might have failed" *>> $logdir"\install_sql.log"
    write-host 'Check Program Files\Microsoft SQL Server\100\Setup Bootstrap\Log for error' *>> $logdir"\install_sql.log"
}
