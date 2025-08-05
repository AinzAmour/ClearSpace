# RecycleBin Cleaning Module
# Empties the Recycle Bin for all drives

Write-ColorOutput "Starting RecycleBin cleaning module..." -Color "Blue"

$cleanedSize = 0

# Get all drives
$drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } # Fixed drives only

foreach ($drive in $drives) {
    $driveLetter = $drive.DeviceID.TrimEnd('\')
    Write-ColorOutput "Cleaning Recycle Bin for drive $driveLetter" -Color "White"
    
    try {
        # Get Recycle Bin size before cleaning
        $recycleBinPath = "$driveLetter`:\`$Recycle.Bin"
        if (Test-Path $recycleBinPath) {
            $beforeSize = (Get-ChildItem -Path $recycleBinPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $beforeSize) { $beforeSize = 0 }
            
            # Empty Recycle Bin using PowerShell
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            
            # Alternative method using cmd
            if ($LASTEXITCODE -ne 0) {
                cmd /c "rd /s /q `"$recycleBinPath`"" 2>$null
            }
            
            # Get size after cleaning
            $afterSize = (Get-ChildItem -Path $recycleBinPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $afterSize) { $afterSize = 0 }
            
            $freedSpace = $beforeSize - $afterSize
            $cleanedSize += $freedSpace
            Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
        } else {
            Write-ColorOutput "  No Recycle Bin found on drive $driveLetter" -Color "Gray"
        }
    }
    catch {
        Write-ColorOutput "  Error cleaning Recycle Bin for drive $driveLetter : $($_.Exception.Message)" -Color "Red"
    }
}

# Also clean user-specific Recycle Bin
Write-ColorOutput "Cleaning user Recycle Bin..." -Color "White"
try {
    $userRecycleBin = [System.Environment]::GetFolderPath('RecycleBin')
    if (Test-Path $userRecycleBin) {
        $beforeSize = (Get-ChildItem -Path $userRecycleBin -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $beforeSize) { $beforeSize = 0 }
        
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        
        $afterSize = (Get-ChildItem -Path $userRecycleBin -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $afterSize) { $afterSize = 0 }
        
        $freedSpace = $beforeSize - $afterSize
        $cleanedSize += $freedSpace
        Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
    }
}
catch {
    Write-ColorOutput "  Error cleaning user Recycle Bin: $($_.Exception.Message)" -Color "Red"
}

Write-ColorOutput "RecycleBin cleaning completed. Total freed: $([math]::Round($cleanedSize / 1MB, 2)) MB" -Color "Green" 