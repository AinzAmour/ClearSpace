# TempFiles Cleaning Module
# Cleans temporary files from various system locations

Write-ColorOutput "Starting TempFiles cleaning module..." -Color "Blue"

$cleanedSize = 0
$locations = @(
    @{ Path = "$env:TEMP"; Description = "User Temp Directory" },
    @{ Path = "$env:SystemRoot\Temp"; Description = "System Temp Directory" },
    @{ Path = "$env:LOCALAPPDATA\Temp"; Description = "Local AppData Temp" },
    @{ Path = "$env:APPDATA\Temp"; Description = "AppData Temp" },
    @{ Path = "$env:USERPROFILE\AppData\Local\Temp"; Description = "User Profile Temp" }
)

foreach ($location in $locations) {
    if (Test-Path $location.Path) {
        Write-ColorOutput "Cleaning: $($location.Description)" -Color "White"
        
        try {
            # Get size before cleaning
            $beforeSize = (Get-ChildItem -Path $location.Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $beforeSize) { $beforeSize = 0 }
            
            # Remove files older than 7 days
            $cutoffDate = (Get-Date).AddDays(-7)
            $filesToRemove = Get-ChildItem -Path $location.Path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
                $_.LastWriteTime -lt $cutoffDate -and -not $_.PSIsContainer
            }
            
            foreach ($file in $filesToRemove) {
                try {
                    Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
                    $cleanedSize += $file.Length
                }
                catch {
                    # Skip files that can't be removed
                }
            }
            
            # Get size after cleaning
            $afterSize = (Get-ChildItem -Path $location.Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            if (-not $afterSize) { $afterSize = 0 }
            
            $freedSpace = $beforeSize - $afterSize
            Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
            
        }
        catch {
            Write-ColorOutput "  Error cleaning $($location.Description): $($_.Exception.Message)" -Color "Red"
        }
    }
}

# Clean Windows Prefetch
if (Test-Path "$env:SystemRoot\Prefetch") {
    Write-ColorOutput "Cleaning: Windows Prefetch" -Color "White"
    try {
        $beforeSize = (Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $beforeSize) { $beforeSize = 0 }
        
        Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*.pf" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        
        $afterSize = (Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $afterSize) { $afterSize = 0 }
        
        $freedSpace = $beforeSize - $afterSize
        Write-ColorOutput "  Freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -Color "Green"
    }
    catch {
        Write-ColorOutput "  Error cleaning Prefetch: $($_.Exception.Message)" -Color "Red"
    }
}

Write-ColorOutput "TempFiles cleaning completed. Total freed: $([math]::Round($cleanedSize / 1MB, 2)) MB" -Color "Green" 