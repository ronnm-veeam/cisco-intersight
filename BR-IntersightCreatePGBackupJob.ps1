Param
(
[Parameter(Mandatory)][string]$protectionGroupName,
[Parameter(Mandatory)][string]$backupJobName,
[Parameter(Mandatory)][string]$backupRepo,
[Parameter(Mandatory)][string]$agentPlatform
)

try {
    $protectionGroup = Get-VBRProtectionGroup -Name $protectionGroupName

    $repository = Get-VBRBackupRepository -Name $backupRepo

    $daily = New-VBRDailyOptions -DayOfWeek Friday -Period 23:00

    switch ($agentPlatform)
    {
        0 {
            $schedule = New-VBRServerScheduleOptions -Type Daily -DailyOptions $daily
            Add-VBRComputerBackupJob -OSPlatform Windows -Type Server -Mode ManagedByBackupServer -BackupObject $protectionGroup `
              -BackupType EntireComputer -Name "$backupJobName" -Description "Cisco Intersight-automated agent backup" `
              -BackupRepository $repository -EnableSchedule -ScheduleOptions $schedule
        }

        1 {
            $schedule = New-VBRServerScheduleOptions -Type Daily -DailyOptions $daily
            Add-VBRComputerBackupJob -OSPlatform Linux -Type Server -Mode ManagedByBackupServer -BackupObject $protectionGroup `
              -BackupType EntireComputer -Name $backupJobName -Description "Cisco Intersight-automated agent backup" `
              -BackupRepository $repository -EnableSchedule -ScheduleOptions $schedule
        }

        Default {
            Write-Output "Unsupported platform"
            exit 1
        }
    }
    exit 0
}
catch {
    Write-Output "Exception in add protection group backup job"
    exit 1
}