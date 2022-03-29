$x = Get-VBRBackupRepository -ScaleOut
foreach ($repo in $x) {
    echo $repo.Name
    $SOBRExtents = Get-VBRRepositoryExtent -Repository $repo.Name
    foreach ($extent in $SOBRExtents) {
        Write-Host "   - " $extent.Name ($extent.Repository.GetContainer().CachedTotalSpace.InBytes / 1GB) ($extent.Repository.GetContainer().CachedFreeSpace.InBytes / 1GB)
        Write-Host "   - " $extent.Name ($extent.Repository.GetContainer().CachedUsedSpace.InBytes / 1GB)
    }
}