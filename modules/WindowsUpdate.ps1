# WindowsUpdate Cleaning Module
# Cleans Windows Update cache and old update files

Write-ColorOutput "Starting WindowsUpdate cleaning module..." -Color "Blue"

$cleanedSize = 0

# Stop Windows Update service temporarily
Write-ColorOutput "Stopping Windows Update service..." -Color "White"
try {
    Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
} catch {
    Write-ColorOutput "  Warning: Could not stop Windows Update service" -Color "Yellow"
}

# Clean Windows Update cache
$wuCachePath = "$env:SystemRoot\SoftwareDistribution\Download"
if (Test-Path $wuCachePath) {
    Write-ColorOutput "Cleaning: Windows Update Download Cache" -Color "White"
    try {
        $beforeSize = (Get-ChildItem -Path $wuCachePath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $beforeSize) { $beforeSize = 0 }
        
        # Remove all files in the download cache
        Get-ChildItem -Path $wuCachePath -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        $afterSize = (Get-ChildItem -Path $wuCachePath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $afterSize) { $afterSize = 0 }
        
        $freedSpace = $beforeSize - $afterSize
        $cleanedSize += $freedSpace
        Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
    }
    catch {
        Write-ColorOutput "  Error cleaning Windows Update cache: $($_.Exception.Message)" -Color "Red"
    }
}

# Clean Windows Update logs
$wuLogPath = "$env:SystemRoot\Logs\WindowsUpdate"
if (Test-Path $wuLogPath) {
    Write-ColorOutput "Cleaning: Windows Update Logs" -Color "White"
    try {
        $beforeSize = (Get-ChildItem -Path $wuLogPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $beforeSize) { $beforeSize = 0 }
        
        # Remove old log files (older than 30 days)
        $cutoffDate = (Get-Date).AddDays(-30)
        Get-ChildItem -Path $wuLogPath -Filter "*.log" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
            $_.LastWriteTime -lt $cutoffDate
        } | Remove-Item -Force -ErrorAction SilentlyContinue
        
        $afterSize = (Get-ChildItem -Path $wuLogPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $afterSize) { $afterSize = 0 }
        
        $freedSpace = $beforeSize - $afterSize
        $cleanedSize += $freedSpace
        Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
    }
    catch {
        Write-ColorOutput "  Error cleaning Windows Update logs: $($_.Exception.Message)" -Color "Red"
    }
}

# Clean DISM and CBS logs
$dismLogPath = "$env:SystemRoot\Logs\DISM"
$cbsLogPath = "$env:SystemRoot\Logs\CBS"

foreach ($logPath in @($dismLogPath, $cbsLogPath)) {
    if (Test-Path $logPath) {
        Write-ColorOutput "Cleaning: $(Split-Path $logPath -Leaf) Logs" -Color "White"
        try {
            $beforeSize = (Get-ChildItem -Path $logPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $beforeSize) { $beforeSize = 0 }
            
            # Remove old log files (older than 30 days)
            $cutoffDate = (Get-Date).AddDays(-30)
            Get-ChildItem -Path $logPath -Filter "*.log" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
                $_.LastWriteTime -lt $cutoffDate
            } | Remove-Item -Force -ErrorAction SilentlyContinue
            
            $afterSize = (Get-ChildItem -Path $logPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $afterSize) { $afterSize = 0 }
            
            $freedSpace = $beforeSize - $afterSize
            $cleanedSize += $freedSpace
            Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
        }
        catch {
            Write-ColorOutput "  Error cleaning $(Split-Path $logPath -Leaf) logs: $($_.Exception.Message)" -Color "Red"
        }
    }
}

# Clean Windows Update cleanup using DISM
Write-ColorOutput "Running DISM cleanup..." -Color "White"
try {
    # Clean up WinSxS component store
    $dismOutput = DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1
    Write-ColorOutput "  DISM cleanup completed" -Color "Green"
}
catch {
    Write-ColorOutput "  Error running DISM cleanup: $($_.Exception.Message)" -Color "Red"
}

# Restart Windows Update service
Write-ColorOutput "Restarting Windows Update service..." -Color "White"
try {
    Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Write-ColorOutput "  Windows Update service restarted" -Color "Green"
} catch {
    Write-ColorOutput "  Warning: Could not restart Windows Update service" -Color "Yellow"
}

Write-ColorOutput "WindowsUpdate cleaning completed. Total freed: $([math]::Round($cleanedSize / 1MB, 2)) MB" -Color "Green" 