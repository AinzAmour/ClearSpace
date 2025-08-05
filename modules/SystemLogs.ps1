# SystemLogs Cleaning Module
# Cleans old system logs and event logs

Write-ColorOutput "Starting SystemLogs cleaning module..." -Color "Blue"

$cleanedSize = 0

# Clean Windows Event Logs
Write-ColorOutput "Cleaning: Windows Event Logs" -Color "White"
try {
    $eventLogs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object { $_.IsEnabled }
    
    foreach ($log in $eventLogs) {
        try {
            $logName = $log.LogName
            $beforeSize = $log.MaximumSizeInBytes
            
            # Clear old events (keep last 1000 events)
            wevtutil cl $logName /q 2>$null
            
            # Get updated log info
            $updatedLog = Get-WinEvent -ListLog $logName -ErrorAction SilentlyContinue
            if ($updatedLog) {
                $afterSize = $updatedLog.MaximumSizeInBytes
                $freedSpace = $beforeSize - $afterSize
                $cleanedSize += $freedSpace
            }
        }
        catch {
            # Skip logs that can't be cleared
        }
    }
    
    Write-ColorOutput "  Event logs cleaned successfully" -Color "Green"
}
catch {
    Write-ColorOutput "  Error cleaning event logs: $($_.Exception.Message)" -Color "Red"
}

# Clean Windows Error Reports
$errorReportPaths = @(
    "$env:LOCALAPPDATA\Microsoft\Windows\WER",
    "$env:ProgramData\Microsoft\Windows\WER"
)

foreach ($path in $errorReportPaths) {
    if (Test-Path $path) {
        Write-ColorOutput "Cleaning: Windows Error Reports ($(Split-Path $path -Leaf))" -Color "White"
        try {
            $beforeSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $beforeSize) { $beforeSize = 0 }
            
            # Remove old error reports (older than 30 days)
            $cutoffDate = (Get-Date).AddDays(-30)
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
                $_.LastWriteTime -lt $cutoffDate
            } | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            
            $afterSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $afterSize) { $afterSize = 0 }
            
            $freedSpace = $beforeSize - $afterSize
            $cleanedSize += $freedSpace
            Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
        }
        catch {
            Write-ColorOutput "  Error cleaning error reports: $($_.Exception.Message)" -Color "Red"
        }
    }
}

# Clean System Restore Points (keep only the latest 3)
Write-ColorOutput "Cleaning: System Restore Points" -Color "White"
try {
    $restorePoints = Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Sort-Object CreationTime -Descending
    
    if ($restorePoints.Count -gt 3) {
        $pointsToRemove = $restorePoints | Select-Object -Skip 3
        
        foreach ($point in $pointsToRemove) {
            try {
                Remove-ComputerRestorePoint -RestorePoint $point.SequenceNumber -ErrorAction SilentlyContinue
            }
            catch {
                # Skip points that can't be removed
            }
        }
        
        Write-ColorOutput "  Removed $($pointsToRemove.Count) old restore points" -Color "Green"
    } else {
        Write-ColorOutput "  No old restore points to remove" -Color "Gray"
    }
}
catch {
    Write-ColorOutput "  Error cleaning restore points: $($_.Exception.Message)" -Color "Red"
}

# Clean Windows Update Logs
$updateLogPaths = @(
    "$env:SystemRoot\Logs\WindowsUpdate",
    "$env:SystemRoot\Logs\CBS",
    "$env:SystemRoot\Logs\DISM"
)

foreach ($path in $updateLogPaths) {
    if (Test-Path $path) {
        Write-ColorOutput "Cleaning: $(Split-Path $path -Leaf) Logs" -Color "White"
        try {
            $beforeSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $beforeSize) { $beforeSize = 0 }
            
            # Remove old log files (older than 60 days)
            $cutoffDate = (Get-Date).AddDays(-60)
            Get-ChildItem -Path $path -Filter "*.log" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
                $_.LastWriteTime -lt $cutoffDate
            } | Remove-Item -Force -ErrorAction SilentlyContinue
            
            $afterSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $afterSize) { $afterSize = 0 }
            
            $freedSpace = $beforeSize - $afterSize
            $cleanedSize += $freedSpace
            Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
        }
        catch {
            Write-ColorOutput "  Error cleaning $(Split-Path $path -Leaf) logs: $($_.Exception.Message)" -Color "Red"
        }
    }
}

# Clean Application Logs
$appLogPaths = @(
    "$env:APPDATA\Microsoft\Windows\Recent",
    "$env:LOCALAPPDATA\Microsoft\Windows\History",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\WebCache"
)

foreach ($path in $appLogPaths) {
    if (Test-Path $path) {
        Write-ColorOutput "Cleaning: $(Split-Path $path -Leaf)" -Color "White"
        try {
            $beforeSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $beforeSize) { $beforeSize = 0 }
            
            # Remove old files (older than 30 days)
            $cutoffDate = (Get-Date).AddDays(-30)
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
                $_.LastWriteTime -lt $cutoffDate -and -not $_.PSIsContainer
            } | Remove-Item -Force -ErrorAction SilentlyContinue
            
            $afterSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $afterSize) { $afterSize = 0 }
            
            $freedSpace = $beforeSize - $afterSize
            $cleanedSize += $freedSpace
            Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
        }
        catch {
            Write-ColorOutput "  Error cleaning $(Split-Path $path -Leaf): $($_.Exception.Message)" -Color "Red"
        }
    }
}

Write-ColorOutput "SystemLogs cleaning completed. Total freed: $([math]::Round($cleanedSize / 1MB, 2)) MB" -Color "Green" 